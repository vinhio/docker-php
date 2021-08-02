## PHP5 Base

PHP5 Base provides a simple and completed PHP5.6.40 environment for the Legacy PHP code. Docker image built on top Alpine OS, Nginx, PHP 5, MySQL 5/8, Redis 4.3.0

- Alpine 3.8
- Nginx 1.2
- PHP 5.6.40 (php-fpm)
- MySQL 5.7.35 / MySQL 8
- Redis 4.3.0

### I. Checking

Run command and check http://localhost:8080

    docker run -p 8080:80 vinhxike/php5

### II. Deploy and Work

Let say code project use MySQL for persistence and Redis for caching. So, We need at least 3 containers.

- Container `MySQL 5.7.35` for MySQL server
- Container `Redis 4.0.14` for Caching server
- Container `vinhxike/php5 latest` for Web application

Every join to docker network `php5base`

#### 1. Create network

    docker network create php5base

#### 2. Start MySQL 

    docker run --name php5base-db --rm -d -h php5base-db \
  		-e MYSQL_ROOT_PASSWORD=secret \
  		-e MYSQL_DATABASE=php5base \
  		-e MYSQL_USER=user \
  		-e MYSQL_PASSWORD=secret \
  		-l SERVICE_NAME=php5base-db \
  		-l SERVICE_3306_NAME=php5base-db \
  		-l SERVICE_33060_NAME=php5base-db \
  		--health-cmd '/usr/bin/mysql --user=user --password=secret --execute "SHOW DATABASES;"' \
  		--health-interval 3s \
  		--health-retries 10 \
  		--health-start-period 3s \
  		--health-timeout 3s \
  		-p 3308:3306 \
  		--network php5base \
  		mysql:5.7.35 \
  		mysqld --character-set-server=utf8 --collation-server=utf8_general_ci

MySQL credentials:

    Username: `user`
    Password: `secret`
    Database: `php5base`
    Root's password: `secret`

#### 3. Start Redis

    docker run --name php5base-redis --rm -d -h php5base-redis \
		-l SERVICE_NAME=php5base-redis \
		--network php5base \
		redis:4.0.14-alpine3.11

#### 4. Start Web server
	
Simple code project folder "/home/vinhxike". So

    /home/vinhxike/app
      |_ /index.php (Just print phpinfo())
      |_ /mysql.php (Check MySQL connection)
      |_ /redis.php (Check Redis connection)

Start web container

    cd /home/vinhxike/app
    docker run --name php5base-web -p 8080:80 -v $(pwd):/home/www/app -l SERVICE_NAME=php5base-web --network php5base vinhxike/php5

#### 5. Docker containers

    docker ps

    CONTAINER ID   IMAGE                     COMMAND                  CREATED          STATUS                    PORTS                                                    NAMES
    bd8a303e9a48   vinhxike/php5             "/init"                  6 seconds ago    Up 4 seconds              0.0.0.0:8080->80/tcp, :::8080->80/tcp                    php5base-web
    0de16a4420b5   redis:4.0.14-alpine3.11   "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes             6379/tcp                                                 php5base-redis
    a20766bf34a9   mysql:5.7.35              "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes (healthy)   33060/tcp, 0.0.0.0:33061->3306/tcp, :::33061->3306/tcp   php5base-db

#### 6. Check MySQL/Redis connection in Web container

Go in `php5base-web`

    docker exec -it -u nginx php5base-web bash

Check Redis (Inside `php5base-web`)

    bash-4.4$ php redis.php
    ....
    Connection to server successful
    Server is running: +PONG
    Stored string in redis:: Redis tutorial

Check MySQL (Inside `php5base-web`)

    bash-4.4$ php mysql.php
    ....
    Connected successfully

You can check all step via HTTP:

    http://localhost:8080/index.php
    http://localhost:8080/mysql.php
    http://localhost:8080/redis.php

#### 7. PHP Code for Example

File `index.php`

    <?php
    phpinfo();

File `redis.php`

    <?php
    //Connecting to Redis server on localhost
    $redis = new Redis();
    $redis->connect('php5base-redis', 6379);
    echo "Connection to server successful";
    
    //check whether server is running or not
    echo "\nServer is running: ".$redis->ping();
    
    //set the data in redis string
    $redis->set("tutorial-name", "Redis tutorial");
    
    // Get the stored data and print it
    echo "\nStored string in redis:: " .$redis->get("tutorial-name");
    echo "\n";

File `mysql.php`

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

### III. Docker composer

You should create `docker-compose.yml` to make everything better!

Good Luck!!!
