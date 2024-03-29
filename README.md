## PHP8 Base

PHP8 Base provides a simple and completed PHP 8 environment for PHP code. Docker image built on top Alpine OS, Nginx, php8, MySQL 5/8, Redis 5

    Version vinhio/php8:8.2.11 : Alpine 3.18, Nginx 1.24, PHP 8.2.11, MySQL 8.2.11, Redis 6.0.1, XDebug 3.2.2
    Version vinhio/php8:8.1.8 : Alpine 3.16, Nginx 1.22, PHP 8.1.8, MySQL 8.1.8, Redis 5.3.7, XDebug 3.1.5
    Version vinhio/php8:8.0.13 : Alpine 3.14.1, Nginx 1.20.2, PHP 8.0.13, MySQL 8.0.13, Redis 5.3.4, XDebug 3.0.4

**Important:** If you want to build docker-php code base on Windows by yourself. Don't forget enable
`dos2unix` in file `docker/Dockerfile.base`

#### PHP plugins:

    php8, php8-intl, php8-openssl, php8-dba, php8-sqlite3, php8-pear, php8-phpdbg, php8-gmp, php8-pdo_mysql, php8-pcntl, php8-common, php8-xsl,
    php8-fpm, php8-mysqli, php8-enchant, php8-pspell, php8-snmp, php8-doc, php8-embed, php8-xmlreader, php8-pdo_sqlite, php8-exif, php8-opcache,
    php8-ldap, php8-posix, php8-gd, php8-gettext, php8-json, php8-xml, php8-iconv, php8-sysvshm, php8-curl, php8-shmop, php8-odbc, php8-phar,
    php8-pdo_pgsql, php8-imap, php8-pdo_dblib, php8-pgsql, php8-pdo_odbc, php8-pecl-xdebug, php8-zip, php8-cgi, php8-ctype, php8-bcmath,
    php8-calendar, php8-dom, php8-sockets, php8-soap, php8-sysvmsg, php8-zlib, php8-ftp, php8-sysvsem, php8-pdo, php8-bz2, php8-tokenizer, php8-xmlwriter,
    php8-fileinfo, php8-mbstring, php8-mysqlnd, php8-session, php8-tidy, php8-simplexml, php8-redis, php8-pecl-imagick, php8-pecl-mcrypt, php8-pecl-apcu

### I. Checking

Run command and check http://localhost:8080

    docker run -p 8080:80 vinhio/php8

### II. Simple App structure

Let say code project use MySQL for persistence, Redis for caching and Mail. So, We need at least 4 containers.

- Container `MySQL 8.0.25` for MySQL server
- Container `Redis 6.2.5` for Caching server
- Container `vinhio/php8 latest` for Web application

#### 1. Code structure

Simple code project folder "/home/vinhio/app". So

    /home/vinhio/app
        |_ /index.php (Just print phpinfo())
        |_ /mysql.php (Check MySQL connection)
        |_ /redis.php (Check Redis connection)
        |_ /ci/docker/docker-compose.yml
        |_ /ci/docker/Dockerfile.yml
        |_ /Makefile

File `index.php`

    <?php
    phpinfo();

File `redis.php`

    <?php
    //Connecting to Redis server on localhost
    $redis = new Redis();
    $redis->connect('myapp-redis', 6379);
    echo "Connect to server successful";

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

File `ci/docker/docker-compose.yml`

    version: '2.1'
    services:

      web:
        build:
          context: ""
          dockerfile: Dockerfile
          args:
            hostUID: 1000
            hostGID: 1000
        image: myapp-web
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
        - ../../:/home/www/app

      db:
        image: mysql:8.0.25
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
        command: mysqld --character-set-server=utf8 --collation-server=utf8_general_ci --default-authentication-plugin=mysql_native_password

      mail:
        image: mailhog/mailhog
        hostname: myapp-mail
        container_name: myapp-mail
        labels:
            SERVICE_NAME: myapp-mail
        ports:
          - '8025:8025'

      redis:
        image: redis:6.2.5-alpine3.14
        hostname: myapp-redis
        container_name: myapp-redis
        labels:
          SERVICE_NAME: myapp-redis

File `ci/docker/Dockerfile`

    FROM vinhio/php8:latest

    VOLUME /home/www/app
    EXPOSE 80 443

    # Replace default nginx user and group with IDs, matching current host user (developer)
    ARG hostUID=1000
    ARG hostGID=1000
    ENV hostUID=$hostUID
    ENV hostGID=$hostGID
    RUN echo "uid:gid=$hostUID:$hostGID" &&\
        oldUID=`id -u nginx` &&\
        deluser nginx &&\
        addgroup -g $hostGID nginx &&\
        adduser -S -u $hostUID -G nginx -h /home/www -s /sbin/nologin nginx &&\
        find /var -user $oldUID -exec chown -v $hostUID:$hostGID {} \;

#### 3. Others

File `Makefile` support run commands quickly

    all: build run

    build:
    	docker-compose -f ci/docker/docker-compose.yml build --no-cache --build-arg hostUID=1000 --build-arg hostGID=1000 web

    start: run

    run:
    	docker-compose -f ci/docker/docker-compose.yml -p myapp up -d web

    stop:
    	docker-compose -f ci/docker/docker-compose.yml -p myapp kill

    destroy:
    	docker-compose -f ci/docker/docker-compose.yml -p myapp down

    logs:
    	docker-compose -f ci/docker/docker-compose.yml -p myapp logs -f web

    shell:
    	docker-compose -f ci/docker/docker-compose.yml -p myapp exec --user nginx web bash

    root:
    	docker-compose -f ci/docker/docker-compose.yml -p myapp exec web bash

    ip:
    	docker inspect myapp-web | grep \"IPAddress\"

#### 3. Start web container

Start docker containers

    cd /home/vinhio/app
    make run

Check docker container status

    docker ps

    CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS                    PORTS                                                    NAMES
    dbbe6281991b   myapp-web                "/init"                  4 seconds ago    Up 3 seconds              443/tcp, 0.0.0.0:8080->80/tcp, :::8080->80/tcp           myapp-web
    722cb84dbab2   mailhog/mailhog          "MailHog"                23 seconds ago   Up 23 seconds             1025/tcp, 0.0.0.0:8025->8025/tcp, :::8025->8025/tcp      myapp-mail
    f6f07c225f7f   mysql:8.0.25             "docker-entrypoint.s…"   23 seconds ago   Up 23 seconds (healthy)   33060/tcp, 0.0.0.0:33060->3306/tcp, :::33060->3306/tcp   myapp-db
    d50b9ba252dc   redis:6.2.5-alpine3.14   "docker-entrypoint.s…"   23 seconds ago   Up 23 seconds             6379/tcp                                                 myapp-redis

Stop docker containers

    make stop

Xóa docker containers

    make destroy

### III. Check results

Go to container `myapp-web`

    docker exec -it -u nginx myapp-web bash

or

    make shell

Check Redis (Inside `myapp-web`. By run `make shell`)

    bash-4.4$ php redis.php
    ....
    Connection to server successful
    Server is running: +PONG
    Stored string in redis:: Redis tutorial

Check MySQL (Inside `myapp-web`. By run `make shell`)

    bash-4.4$ php mysql.php
    ....
    Connected successfully

You can check all steps via HTTP:

    http://localhost:8080/index.php
    http://localhost:8080/mysql.php
    http://localhost:8080/redis.php

Good Luck!!!
