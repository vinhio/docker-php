<?php
$servername = "db";
$username = "user";
$password = "secret";
$dbname = "php5";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("\nConnection failed: " . $conn->connect_error);
}
echo "\nConnected successfully";

// sql to create table
$sql = "CREATE TABLE MyGuests (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(30) NOT NULL,
    lastname VARCHAR(30) NOT NULL,
    email VARCHAR(50),
    reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )";

if ($conn->query($sql) === TRUE) {
    echo "\nTable MyGuests created successfully";
} else {
    echo "\nError creating table: " . $conn->error;
}
echo "\n";

$conn->close();