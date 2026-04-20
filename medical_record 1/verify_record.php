<?php
// verify_record.php
// ITD clicks this link from the email to approve a medical record.
// UPDATED: Also creates an inbox notification for the patient.

require_once("../config.php");

$record_id = $_GET['id'] ?? '';

if (!$record_id || !is_numeric($record_id)) {
    http_response_code(400);
    echo "
    <html><body style='font-family:Arial;text-align:center;padding:60px;'>
    <h2 style='color:red;'>Invalid or missing record ID.</h2>
    <p>Please check the link in your email and try again.</p>
    </body></html>";
    exit;
}

// Get record details including patient's user_id
$check = $conn->prepare("
    SELECT record_verified, record_name, record_date, user_id
    FROM medical_record
    WHERE record_id = ?
");
$check->bind_param("i", $record_id);
$check->execute();
$result = $check->get_result();
$row = $result->fetch_assoc();

if (!$row) {
    http_response_code(404);
    echo "
    <html><body style='font-family:Arial;text-align:center;padding:60px;'>
    <h2 style='color:red;'>Record not found.</h2>
    </body></html>";
    exit;
}

if ($row['record_verified'] == 1) {
    echo "
    <html><body style='font-family:Arial;text-align:center;padding:60px;'>
    <h2 style='color:#2E7D32;'>Already Verified</h2>
    <p>The record <strong>{$row['record_name']}</strong> has already been verified.</p>
    </body></html>";
    exit;
}

// Step 1: Mark record as verified 
$stmt = $conn->prepare("
    UPDATE medical_record
    SET record_verified = 1, updated_at = NOW()
    WHERE record_id = ?
");
$stmt->bind_param("i", $record_id);

if (!$stmt->execute()) {
    http_response_code(500);
    echo "
    <html><body style='font-family:Arial;text-align:center;padding:60px;'>
    <h2 style='color:red;'>Verification Failed</h2>
    <p>Error: " . $stmt->error . "</p>
    </body></html>";
    exit;
}

// Step 2: Create inbox notification for the patient 
$user_id      = $row['user_id'];
$record_name  = $row['record_name'];
$notif_type   = 'medical_record';
$notif_title  = 'Medical Report Available';
$notif_message = "Your medical report \"$record_name\" has been verified and is now available in the app.";

$notifStmt = $conn->prepare("
    INSERT INTO notification (user_id, notif_type, notif_title, notif_message, reference_id)
    VALUES (?, ?, ?, ?, ?)
");
$notifStmt->bind_param("ssssi", $user_id, $notif_type, $notif_title, $notif_message, $record_id);
$notifStmt->execute(); // non-critical — don't fail the verify if this fails
$notifStmt->close();

$stmt->close();
$conn->close();

// Show success page to ITD
echo "
<html><body style='font-family:Arial;text-align:center;padding:60px;background:#f9f9f9;'>
<div style='max-width:500px;margin:auto;background:#fff;padding:40px;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,0.1);'>
  <h1 style='color:#2E7D32;'>Medical Record Verified!</h1>
  <p style='font-size:16px;'>The record <strong>$record_name</strong> has been verified.</p>
  <p style='color:#555;'>The patient will now see a notification in their app inbox and can view the report.</p>
  <p style='color:#aaa;font-size:13px;margin-top:30px;'>— NMSC Mobile Application System</p>
</div>
</body></html>";
?>