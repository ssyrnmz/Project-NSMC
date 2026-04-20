<?php
    require_once("../config.php");
    require_once("../validate.php");

    validateUser();

    if (!isset($_FILES['file'])) {
        echo "Error, No file exists";
        exit;
    }

    $file = $_FILES['file'];

    // Get extension
    $filename = $_FILES['file']['name'];     
    $ext = pathinfo($filename, PATHINFO_EXTENSION);
     
    if (strtolower($ext) !== 'pdf') {
    echo "Only PDF allowed";
    exit;
    }


    // Create the name for the uploaded pd
    $uploadName = bin2hex(random_bytes(16)) . 'normah.' . $ext;
    
    // Get directory and the full path of the file to be uploaded
    $uploadDirectory = realpath(__DIR__ . '/../../../uploads/app_nmsc/record');

    // If folder does not exist yet
    if (!is_dir($uploadDirectory)) {
        mkdir($uploadDirectory, 0755, true);
    }

    $uploadPath = $uploadDirectory . '/' . $uploadName;

    if (move_uploaded_file($file['tmp_name'], $uploadPath)) {
        echo json_encode($uploadName);
    }
?>