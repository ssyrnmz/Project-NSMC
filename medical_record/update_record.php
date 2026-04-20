<?php
    require_once("../config.php");
    require_once("../validate.php");

    validateUser();
    
    $data = json_decode(file_get_contents("php://input"), true);
    $record_id          = $data["id"];
    $record_name        = $data["name"];
    $record_date        = $data["date"];
    $record_file        = $data["file"];
    $user_id            = $data["userId"];
    $record_archived    = $data["archived"]; 

    $updateSQL =
    "UPDATE medical_record SET
        record_name = ?,
        record_date = ?,
        record_file = ?,
        user_id = ?,
        record_archived = ?
    WHERE record_id = ?";

    $stmt = $conn->prepare($updateSQL);

    if (!$stmt) {
        die("Prepare failed: " . $conn->error);
    }

    $stmt->bind_param(
        "ssssii",
        $record_name,
        $record_date,
        $record_file,
        $user_id,
        $record_archived,
        $record_id
    );

    if ($stmt->execute()) {
        $result = $stmt->get_result();
        echo json_encode($result);
    }

    $stmt->close();  
?>