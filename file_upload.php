<?php 
$response = new stdClass;
$response->status = null;
$response->message = null;


$directory = "upload/"; //saving destination


if (isset($_FILES["file"])):

    $file_name = $_FILES["file"]["name"];

   $temp = explode(".", $file_name); // file extention

   $target_file = $directory .round(microtime(true)) . '.' . end($temp);
   
    move_uploaded_file($_FILES["file"]["tmp_name"], $target_file);
        $response->status = false;
        $return["success"] = true;
        $response->message = "file uploaded successfully";
else:
    $response->status = false;
    $response->message = "No File Sublitted |";
endif;

header('Content-type: application/json');
header("Access-Control-Allow-Origin: *");
echo json_encode($response); 
?> 