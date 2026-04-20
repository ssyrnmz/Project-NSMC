<?php
// add_record.php — saves new medical record with status = 'pending'
// and sends email to portal@normah.com for verification
require_once("../config.php");
require_once("../validate.php");

validateUser();

$data = json_decode(file_get_contents("php://input"), true);

$name       = $data['name']     ?? '';
$date       = $data['date']     ?? '';
$file       = $data['file']     ?? '';
$userId     = $data['userId']   ?? '';

if (!$name || !$date || !$file || !$userId) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing required fields.']);
    exit;
}

// Convert ISO date to MySQL DATE
$recordDate = date('Y-m-d', strtotime($date));

// Insert with status = 'pending'
$stmt = $conn->prepare(
    "INSERT INTO medical_record (record_name, record_date, record_file, user_id, record_archived, record_status)
     VALUES (?, ?, ?, ?, 0, 'pending')"
);
$stmt->bind_param("ssss", $name, $recordDate, $file, $userId);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to save record: ' . $stmt->error]);
    exit;
}

$newId = $conn->insert_id;
$stmt->close();

// Send verification email to ITD
// Build a secure verify link (token = base64 of id + secret)
$secret = 'nmsc_itd_verify_secret_2026'; // Change this to a strong secret
$token  = base64_encode($newId . ':' . hash('sha256', $newId . $secret));

// This is the URL to your verify_record.php (hosted on your server)
// Replace with your actual ngrok/domain URL
$baseUrl    = 'https://semiarid-servantlike-daren.ngrok-free.dev/nmsc_app/';
$verifyUrl  = $baseUrl . 'medical_record/verify_record.php?id=' . $newId . '&token=' . urlencode($token);
$rejectUrl  = $baseUrl . 'medical_record/verify_record.php?id=' . $newId . '&token=' . urlencode($token) . '&action=reject';

// Use PHP's built-in mail() function
// Note: For production, use PHPMailer (already in vendor/) for better reliability
$to      = 'portal@normah.com';
$subject = '[NMSC App] New Medical Report Requires Verification';
$message = "
<html>
<body style='font-family: Arial, sans-serif; color: #333;'>
  <h2 style='color: #4D7C4A;'>Medical Report Verification Request</h2>
  <p>A new medical report has been uploaded for a patient and requires your verification before it is released.</p>

  <table style='border-collapse: collapse; width: 100%;'>
    <tr>
      <td style='padding: 8px; font-weight: bold;'>Report Name:</td>
      <td style='padding: 8px;'>$name</td>
    </tr>
    <tr style='background: #f9f9f9;'>
      <td style='padding: 8px; font-weight: bold;'>Record Date:</td>
      <td style='padding: 8px;'>$recordDate</td>
    </tr>
    <tr>
      <td style='padding: 8px; font-weight: bold;'>Record ID:</td>
      <td style='padding: 8px;'>$newId</td>
    </tr>
  </table>

  <br>
  <p>Please click one of the buttons below to verify or reject this report:</p>

  <a href='$verifyUrl'
     style='display:inline-block; padding:12px 28px; background:#4D7C4A; color:white;
            text-decoration:none; border-radius:6px; margin-right:12px; font-size:15px;'>
    Approve & Release to Patient
  </a>

  <a href='$rejectUrl'
     style='display:inline-block; padding:12px 28px; background:#D32F2F; color:white;
            text-decoration:none; border-radius:6px; font-size:15px;'>
    Reject Report
  </a>

  <br><br>
  <p style='color: #888; font-size: 12px;'>
    This email was sent automatically by the NMSC Mobile Application system.<br>
    Do not reply to this email.
  </p>
</body>
</html>
";

$headers  = "MIME-Version: 1.0\r\n";
$headers .= "Content-Type: text/html; charset=UTF-8\r\n";
$headers .= "From: noreply@normah.com\r\n";

mail($to, $subject, $message, $headers);
// Note: If mail() doesn't work, switch to PHPMailer — see comments below
/*
  PHPMailer alternative (more reliable):
  require_once '../vendor/autoload.php';
  use PHPMailer\PHPMailer\PHPMailer;
  $mail = new PHPMailer(true);
  $mail->isSMTP();
  $mail->Host       = 'smtp.normah.com'; // Your SMTP host
  $mail->SMTPAuth   = true;
  $mail->Username   = 'noreply@normah.com';
  $mail->Password   = 'your_password';
  $mail->SMTPSecure = 'tls';
  $mail->Port       = 587;
  $mail->setFrom('noreply@normah.com', 'NMSC App');
  $mail->addAddress('portal@normah.com');
  $mail->isHTML(true);
  $mail->Subject = $subject;
  $mail->Body    = $message;
  $mail->send();
*/

http_response_code(200);
echo json_encode(['message' => 'Record saved and verification email sent.']);
$conn->close();
?>