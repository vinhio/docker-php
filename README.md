## PHP5 Base

PHP5 Base provides a simple and completed PHP 5 environment for the Legacy PHP code. Docker image built on top Alpine OS, Nginx, PHP 5, MySQL 5/8, Redis 4

- Alpine 3.8
- Nginx 1.2
- PHP 5.6.40 (php-fpm)
- MySQL 5.7.35 / MySQL 8
- Redis 4.3.0
- XDebug 2.5.5

**Important:** If you want to build docker-php code base on Windows by yourself. Don't forget enable 
`dos2unix` in file `docker/Dockerfile.base`

#### PHP plugins:

    php5
	php5-intl
	php5-openssl
	php5-dba
	php5-sqlite3
	php5-pear
	php5-phpdbg
	php5-gmp
	php5-pdo_mysql
	php5-pcntl
	php5-common
	php5-xsl
	php5-fpm	
	php5-mysql
	php5-mysqli
	php5-enchant
	php5-pspell
	php5-snmp
	php5-doc
	php5-xmlrpc
	php5-embed
	php5-xmlreader
	php5-pdo_sqlite
	php5-exif
	php5-opcache
	php5-ldap
	php5-posix	
	php5-gd
	php5-gettext
	php5-json
	php5-xml
	php5-iconv
	php5-sysvshm
	php5-curl
	php5-shmop
	php5-odbc
	php5-phar
	php5-pdo_pgsql
	php5-imap
	php5-pdo_dblib
	php5-pgsql
	php5-pdo_odbc
	php5-zip
	php5-cgi
	php5-ctype
	php5-mcrypt
	php5-wddx
	php5-bcmath
	php5-calendar
	php5-dom
	php5-sockets
	php5-soap
	php5-apcu
	php5-sysvmsg
	php5-zlib
	php5-ftp
	php5-sysvsem 
	php5-pdo
	php5-bz2
	php5-redis
    php5-mbstring
    php5-tokenizer

### I. Checking

Run command and check http://localhost:8080

    docker run -p 8080:80 vinhio/php5

### II. Deploy and Work

Let say code project use MySQL for persistence and Redis for caching. So, We need at least 3 containers.

- Container `MySQL 5.7.35` for MySQL server
- Container `Redis 4.0.14` for Caching server
- Container `vinhio/php5 latest` for Web application

Every join to docker network `myapp`

#### 1. Create network

    docker network create myapp

#### 2. Start MySQL 

    docker run --name myapp-db --rm -d -h myapp-db \
  		-e MYSQL_ROOT_PASSWORD=secret \
  		-e MYSQL_DATABASE=myapp \
  		-e MYSQL_USER=user \
  		-e MYSQL_PASSWORD=secret \
  		-l SERVICE_NAME=myapp-db \
  		-l SERVICE_3306_NAME=myapp-db \
  		-l SERVICE_33060_NAME=myapp-db \
  		--health-cmd '/usr/bin/mysql --user=user --password=secret --execute "SHOW DATABASES;"' \
  		--health-interval 3s \
  		--health-retries 10 \
  		--health-start-period 3s \
  		--health-timeout 3s \
  		-p 3308:3306 \
  		--network myapp \
  		mysql:5.7.35 \
  		mysqld --character-set-server=utf8 --collation-server=utf8_general_ci

MySQL credentials:

    Username: `user`
    Password: `secret`
    Database: `myapp`
    Root's password: `secret`

#### 3. Start Redis

    docker run --name myapp-redis --rm -d -h myapp-redis \
		-l SERVICE_NAME=myapp-redis \
		--network myapp \
		redis:4.0.14-alpine3.11

#### 4. Start Web server
	
Simple code project folder "/home/vinhio". So

    /home/vinhio/app
      |_ /index.php (Just print phpinfo())
      |_ /mysql.php (Check MySQL connection)
      |_ /redis.php (Check Redis connection)

Start web container

    cd /home/vinhio/app
    docker run --name myapp-web -p 8080:80 -v $(pwd):/home/www/app -l SERVICE_NAME=myapp-web --network myapp vinhio/php5

#### 5. Docker containers

    docker ps

    CONTAINER ID   IMAGE                     COMMAND                  CREATED          STATUS                    PORTS                                                    NAMES
    bd8a303e9a48   vinhio/php5             "/init"                  6 seconds ago    Up 4 seconds              0.0.0.0:8080->80/tcp, :::8080->80/tcp                    myapp-web
    0de16a4420b5   redis:4.0.14-alpine3.11   "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes             6379/tcp                                                 myapp-redis
    a20766bf34a9   mysql:5.7.35              "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes (healthy)   33060/tcp, 0.0.0.0:33061->3306/tcp, :::33061->3306/tcp   myapp-db

#### 6. Check MySQL/Redis connection in Web container

Go in `myapp-web`

    docker exec -it -u nginx myapp-web bash

Check Redis (Inside `myapp-web`)

    bash-4.4$ php redis.php
    ....
    Connection to server successful
    Server is running: +PONG
    Stored string in redis:: Redis tutorial

Check MySQL (Inside `myapp-web`)

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
    $redis->connect('myapp-redis', 6379);
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
    $servername = "myapp-db";
    $username = "user";
    $password = "secret";
    $dbname = "myapp";
    
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

### III. Docker compose

File `docker-compose.yml`

    version: '2.1'
    services:
    
      web:
        image: vinhio/php5
        hostname: myapp-web
        container_name: myapp-web
        labels:
          SERVICE_NAME: myapp-web
          SERVICE_80_NAME: myapp-web
          SERVICE_443_NAME: myapp-web
        ports:
         - '8080:80'
        depends_on:
          db:
            condition: service_healthy
          mail:
            condition: service_started
          redis:
            condition: service_started
        environment:
          APP_ENV: local
          PHP_IDE_CONFIG: serverName=myapp-web.service.docker
        volumes:
        - ./:/home/www/app
    
      db:
        image: mysql:5.7.35
        #image: mysql:8.0.25
        hostname: myapp-db
        container_name: myapp-db
        environment:
          MYSQL_ROOT_PASSWORD: secret
          MYSQL_DATABASE: myapp
          MYSQL_USER: user
          MYSQL_PASSWORD: secret
        labels:
          SERVICE_NAME: myapp-db
          SERVICE_3306_NAME: myapp-db
          SERVICE_33060_NAME: myapp-db
        ports:
          - '33060:3306'
        healthcheck:
          test: "/usr/bin/mysql --user=user --password=secret --execute \"SHOW DATABASES;\""
          interval: 3s
          timeout: 3s
          retries: 10
        command: mysqld --character-set-server=utf8 --collation-server=utf8_general_ci
        #command: mysqld --character-set-server=utf8 --collation-server=utf8_general_ci --default-authentication-plugin=mysql_native_password
    
      mail:
        image: mailhog/mailhog
        hostname: myapp-mail
        container_name: myapp-mail
        labels:
            SERVICE_NAME: myapp-mail
        ports:
          - '8025:8025'
    
      redis:
        image: redis:4.0.14-alpine3.11
        hostname: myapp-redis
        container_name: myapp-redis
        labels:
          SERVICE_NAME: myapp-redis


File `Makefile`

    all: run
	
	start: run
	
	run:
		docker-compose -f docker-compose.yml -p myapp up -d web
	
	stop:
		docker-compose -f docker-compose.yml -p myapp kill
	
	destroy:
		docker-compose -f docker-compose.yml -p myapp down
	
	logs:
		docker-compose -f docker-compose.yml -p myapp logs -f web
	
	shell:
		docker-compose -f docker-compose.yml -p myapp exec --user nginx web bash
	
	root:
		docker-compose -f docker-compose.yml -p myapp exec web bash
	
	ip:
		docker inspect myapp-web | grep \"IPAddress\"

Good Luck!!!
