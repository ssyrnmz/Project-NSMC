<?php
require_once("../config.php");
require_once("../validate.php");

validateUser();

// Get record id from POST body (Flutter sends as POST)
$data = json_decode(file_get_contents("php://input"), true);
$id = $data['id'] ?? $_POST['id'] ?? $_GET['id'] ?? '';

if (!$id) {
    http_response_code(400);
    echo "Missing ID";
    exit;
}

// Get file path from DB
$stmt = $conn->prepare("SELECT record_file FROM medical_record WHERE record_id = ?");
if (!$stmt) {
    http_response_code(500);
    die("Prepare failed: " . $conn->error);
}

$stmt->bind_param("i", $id);

if (!$stmt->execute()) {
    http_response_code(500);
    die("Execute failed: " . $stmt->error);
}

$result = $stmt->get_result();
$row = $result->fetch_assoc();

if (!$row) {
    http_response_code(404);
    echo "Record not found";
    exit;
}

$filename = $row['record_file'];

// Match the SAME path used in save_file_record.php
$filePath = realpath(__DIR__ . '/../../../uploads/app_nmsc/record') . '/' . $filename;

// Check if file exists
if (!file_exists($filePath)) {
    http_response_code(404);
    echo "File not found at: " . $filePath;
    exit;
}

// Clear output buffer
if (ob_get_level()) {
    ob_end_clean();
}

// Send headers
header('Content-Type: application/pdf');
header('Content-Disposition: inline; filename="' . $filename . '"');
header('Content-Length: ' . filesize($filePath));
header('Cache-Control: no-cache, must-revalidate');
header('Pragma: public');

// Output file
readfile($filePath);
exit;
?>