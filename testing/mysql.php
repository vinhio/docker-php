<?php
$servername = "php5base-db";
$username = "user";
$password = "secret";
$dbname = "php5base";

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