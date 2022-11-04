<?php
$servername = "db";
$username = "user";
$password = "secret";
$dbname = "myapp";

$servername = "host.docker.internal";
$username = "root";
$password = "admin!@#";
$dbname = "mysql";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("\nConnection failed: " . $conn->connect_error);
}
echo "\nConnected successfully";
echo "\n";

// Close DB connection
$conn->close();
