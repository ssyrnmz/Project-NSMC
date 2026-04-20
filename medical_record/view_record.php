<?php
// view_record.php
// Serves a medical record PDF for viewing in browser
// GET param: id = record_id
require_once("../config.php");
require_once("../validate.php");

validateUser();

$id = $_GET['id'] ?? '';

if (!$id) {
    http_response_code(400);
    echo "Missing ID";
    exit;
}

$stmt = $conn->prepare("SELECT record_file FROM medical_record WHERE record_id = ?");
$stmt->bind_param("i", $id);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

if (!$row) {
    http_response_code(404);
    echo "Record not found";
    exit;
}

$filename = $row['record_file'];
$filePath = realpath(__DIR__ . '/../../../uploads/app_nmsc/record') . '/' . $filename;

if (!file_exists($filePath)) {
    http_response_code(404);
    echo "File not found";
    exit;
}

if (ob_get_level()) ob_end_clean();

header('Content-Type: application/pdf');
header('Content-Disposition: inline; filename="medical_record.pdf"');
header('Content-Length: ' . filesize($filePath));
header('Cache-Control: no-cache');

readfile($filePath);
exit;
?>