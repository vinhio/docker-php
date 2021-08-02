<?php
//Connecting to Redis server on localhost
$redis = new Redis();
$redis->connect('redis', 6379);
echo "Connection to server successful";
//check whether server is running or not
echo "\nServer is running: ".$redis->ping();
//set the data in redis string
$redis->set("tutorial-name", "Redis tutorial");
// Get the stored data and print it
echo "\nStored string in redis:: " .$redis->get("tutorial-name");
echo "\n";