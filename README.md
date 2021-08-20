## PHP7 Base

PHP7 Base provides a simple and completed PHP 7 environment for PHP code. Docker image built on top Alpine OS, Nginx, PHP 7, MySQL 5/8, Redis 5

- Alpine 3.14.1
- Nginx 1.20.1
- PHP 7.4.22 (php-fpm)
- MySQL 5.7.35 / 8.0.25
- Redis 5.3.4
- XDebug 3.0.4 

**Important:** If you want to build docker-php code base on Windows by yourself. Don't forget enable 
`dos2unix` in file `docker/Dockerfile.base`

#### PHP plugins:
    
    php7
    php7-intl
    php7-openssl
    php7-dba
    php7-sqlite3
    php7-pear
    php7-phpdbg
    php7-gmp
    php7-pdo_mysql
    php7-pcntl
    php7-common
    php7-xsl
    php7-fpm
    php7-mysqli
    php7-enchant
    php7-pspell
    php7-snmp
    php7-doc
    php7-xmlrpc
    php7-embed
    php7-xmlreader
    php7-pdo_sqlite
    php7-exif
    php7-opcache
    php7-ldap
    php7-posix
    php7-gd
    php7-gettext
    php7-json
    php7-xml
    php7-iconv
    php7-sysvshm
    php7-curl
    php7-shmop
    php7-odbc
    php7-phar
    php7-pdo_pgsql
    php7-imap
    php7-pdo_dblib
    php7-pgsql
    php7-pdo_odbc
    php7-pecl-xdebug
    php7-zip
    php7-cgi
    php7-ctype
    php7-mcrypt
    php7-bcmath
    php7-calendar
    php7-dom
    php7-sockets
    php7-soap
    php7-apcu
    php7-sysvmsg
    php7-zlib
    php7-ftp
    php7-sysvsem
    php7-pdo
    php7-bz2
    php7-tokenizer
    php7-xmlwriter
    php7-fileinfo
    php7-mbstring
    php7-mysqlnd
    php7-session
    php7-tidy
    php7-simplexml
    php7-redis
    php7-imagick
    php7-pecl-apcu

### I. Checking

Run command and check http://localhost:8080

    docker run -p 8080:80 vinhxike/php7

### II. Simple App structure

Let say code project use MySQL for persistence and Redis for caching. So, We need at least 3 containers.

- Container `MySQL 5.7.35` for MySQL server
- Container `Redis 4.0.14` for Caching server
- Container `vinhxike/php7 latest` for Web application

#### 1. Code structure

Simple code project folder "/home/vinhxike/app". So

    /home/vinhxike/app
        |_ /index.php (Just print phpinfo())
        |_ /mysql.php (Check MySQL connection)
        |_ /redis.php (Check Redis connection)
        |_ /docker-compose.yml
        |_ /Makefile 


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

#### 2. Docker compose

File `docker-compose.yml`

    version: '2.1'
    services:
    
      web:
        image: vinhxike/php7
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

#### 3. Start web container

Start docker containers 

    cd /home/vinhxike/app
    make run

Check docker container status

    docker ps

    CONTAINER ID   IMAGE                     COMMAND                  CREATED          STATUS                    PORTS                                                    NAMES
    bd8a303e9a48   vinhxike/php7             "/init"                  6 seconds ago    Up 4 seconds              0.0.0.0:8080->80/tcp, :::8080->80/tcp                    myapp-web
    0de16a4420b5   redis:4.0.14-alpine3.11   "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes             6379/tcp                                                 myapp-redis
    a20766bf34a9   mysql:5.7.35              "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes (healthy)   33060/tcp, 0.0.0.0:33061->3306/tcp, :::33061->3306/tcp   myapp-db

### III. Check results

Go to container `myapp-web`

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

Good Luck!!!
