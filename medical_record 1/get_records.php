<?php
// get_records.php
// Patient (no role param) only verified records (record_verified = 1)
// Admin (?role=admin) all records including pending (record_verified = 0)
require_once("../config.php");
require_once("../validate.php");
 
validateUser();
 
$id   = $_GET['id']   ?? '';
$sync = $_GET['sync'] ?? null;
$role = $_GET['role'] ?? 'user';
 
if (!$id) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing user id.']);
    exit;
}
 
// Patient only sees verified records; admin sees all
$verifiedFilter = ($role === 'admin') ? '' : 'AND record_verified = 1';
 
if ($sync) {
    $sql = "SELECT record_id, record_name, record_date, record_file, user_id,
                   record_archived, record_verified, updated_at
            FROM medical_record
            WHERE user_id = ? AND record_archived = 0 $verifiedFilter AND updated_at > ?
            ORDER BY record_date DESC";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $id, $sync);
} else {
    $sql = "SELECT record_id, record_name, record_date, record_file, user_id,
                   record_archived, record_verified, updated_at
            FROM medical_record
            WHERE user_id = ? AND record_archived = 0 $verifiedFilter
            ORDER BY record_date DESC";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $id);
}
 
$stmt->execute();
$result  = $stmt->get_result();
$records = [];
 
while ($row = $result->fetch_assoc()) {
    $records[] = $row;
}
 
$stmt->close();
$conn->close();
 
echo json_encode($records);
?>