<?php
// notify_itd.php
// Called right after admin uploads a medical record.
// Sends an email to portal@normah.com with the patient + record details
// so ITD can review and verify using the verify_record.php link.

require_once("../config.php");
require_once("../validate.php");

validateUser(); // Only authenticated admins can trigger this

// Read request body
$data = json_decode(file_get_contents("php://input"), true);

$record_id      = $data['record_id']      ?? '';
$record_name    = $data['record_name']    ?? '';
$record_date    = $data['record_date']    ?? '';
$patient_name   = $data['patient_name']   ?? '';
$patient_email  = $data['patient_email']  ?? '';
$patient_ic     = $data['patient_ic']     ?? '';
$uploaded_by    = $data['uploaded_by']    ?? 'Admin'; // admin's name

if (!$record_id) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing record_id']);
    exit;
}

//Build the verify link (ITD clicks this to approve)
// verify_record.php sets record_verified = 1 in the DB
$base_url    = 'https://semiarid-servantlike-daren.ngrok-free.dev/nmsc_app/';
$verify_link = $base_url . 'medical_record/verify_record.php?id=' . urlencode($record_id);

//Build email HTML 
$subject = "Medical Record Verification Required � NMSC App";

$body = "
<!DOCTYPE html>
<html>
<body style='font-family: Arial, sans-serif; color: #333; padding: 20px;'>
  <h2 style='color: #2E7D32;'>NMSC Mobile App � Medical Record Verification</h2>
  <p>A new medical record has been uploaded and requires your verification before the patient can access it.</p>

  <table style='border-collapse: collapse; width: 100%; max-width: 600px;'>
    <tr style='background:#f5f5f5;'>
      <td style='padding:10px; border:1px solid #ddd; font-weight:bold;'>Record ID</td>
      <td style='padding:10px; border:1px solid #ddd;'>{$record_id}</td>
    </tr>
    <tr>
      <td style='padding:10px; border:1px solid #ddd; font-weight:bold;'>Record Name</td>
      <td style='padding:10px; border:1px solid #ddd;'>{$record_name}</td>
    </tr>
    <tr style='background:#f5f5f5;'>
      <td style='padding:10px; border:1px solid #ddd; font-weight:bold;'>Record Date</td>
      <td style='padding:10px; border:1px solid #ddd;'>{$record_date}</td>
    </tr>
    <tr>
      <td style='padding:10px; border:1px solid #ddd; font-weight:bold;'>Patient Name</td>
      <td style='padding:10px; border:1px solid #ddd;'>{$patient_name}</td>
    </tr>
    <tr style='background:#f5f5f5;'>
      <td style='padding:10px; border:1px solid #ddd; font-weight:bold;'>Patient Email</td>
      <td style='padding:10px; border:1px solid #ddd;'>{$patient_email}</td>
    </tr>
    <tr>
      <td style='padding:10px; border:1px solid #ddd; font-weight:bold;'>Patient IC Number</td>
      <td style='padding:10px; border:1px solid #ddd;'>{$patient_ic}</td>
    </tr>
    <tr style='background:#f5f5f5;'>
      <td style='padding:10px; border:1px solid #ddd; font-weight:bold;'>Uploaded By</td>
      <td style='padding:10px; border:1px solid #ddd;'>{$uploaded_by}</td>
    </tr>
  </table>

  <br>
  <p>To <strong>approve and make this record visible to the patient</strong>, click the button below:</p>

  <a href='{$verify_link}' 
     style='display:inline-block; padding:14px 28px; background:#2E7D32; color:#fff;
            text-decoration:none; border-radius:6px; font-size:16px; font-weight:bold;'>Verify Medical Record
  </a>

  <br><br>
  <p style='color:#888; font-size:13px;'>
    If you did not expect this email, please contact the NMSC admin team.<br>
    This link can only be used once.
  </p>

  <p style='color:#888; font-size:12px;'>� NMSC Mobile Application System</p>
</body>
</html>
";

// Send email using PHP mail()
// If your server uses SMTP (e.g. PHPMailer), replace mail() with that instead.
$to      = 'portal@normah.com';
$headers = implode("\r\n", [
    'MIME-Version: 1.0',
    'Content-Type: text/html; charset=UTF-8',
    'From: NMSC App <no-reply@normah.com>',
    'Reply-To: no-reply@normah.com',
    'X-Mailer: PHP/' . phpversion(),
]);

$sent = mail($to, $subject, $body, $headers);

if ($sent) {
    http_response_code(200);
    echo json_encode(['success' => true, 'message' => 'Verification email sent to ITD.']);
} else {
    // Don't block the upload flow � just log the failure
    http_response_code(200);
    echo json_encode(['success' => false, 'message' => 'Record saved but email could not be sent.']);
}
?>