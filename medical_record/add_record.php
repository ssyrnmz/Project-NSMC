<?php
// add_record.php — saves new medical record with record_verified = 0 (pending)
// Returns JSON with record details so Flutter can pass record_id to notify_itd.php
require_once("../config.php");
require_once("../validate.php");

validateUser();

$data = json_decode(file_get_contents("php://input"), true);

$name     = $data['name']     ?? '';
$date     = $data['date']     ?? '';
$file     = $data['file']     ?? '';
$userId   = $data['userId']   ?? '';
$archived = isset($data['archived']) ? intval($data['archived']) : 0;

if (!$name || !$date || !$file || !$userId) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing required fields.']);
    exit;
}

// Convert ISO date to MySQL DATE
$recordDate = date('Y-m-d', strtotime($date));

// Insert with record_verified = 0 (hidden from patient until portal approves)
$stmt = $conn->prepare(
    "INSERT INTO medical_record (record_name, record_date, record_file, user_id, record_archived, record_verified)
     VALUES (?, ?, ?, ?, ?, 0)"
);
$stmt->bind_param("ssssi", $name, $recordDate, $file, $userId, $archived);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to save record: ' . $stmt->error]);
    exit;
}

$newId = $conn->insert_id;
$stmt->close();
$conn->close();

// Return full record JSON so Flutter can read record_id
echo json_encode([
    'record_id'       => $newId,
    'record_name'     => $name,
    'record_date'     => $recordDate,
    'record_file'     => $file,
    'user_id'         => $userId,
    'record_archived' => $archived,
    'record_verified' => 0,
    'updated_at'      => date('Y-m-d H:i:s'),
]);
?>