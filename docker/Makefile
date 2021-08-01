# Convert docker command to docker-compose command https://www.composerize.com/

#TEST_ROOT = ../..
#include ${TEST_ROOT}/include/common.makefile
PWD = $(shell pwd)

all: build run

build:
	# Step 1: Build image
	docker build -f docker/Dockerfile.base -t php5-base docker
	docker build -f docker/Dockerfile.local --build-arg hostUID=1000 --build-arg hostGID=1000 -t php5-web docker/
	# Step 2. Create network
	docker network create php5
	#docker network inspect php5 | grep <???>
	# Step 2.1. Add container to network
	#docker network connect php5 php5-mail
	#docker network connect php5 php5-db
	#docker network connect php5 php5-web

start: run

run:
	# Step 3. Run mail server with instance name `php5-mail` and host name `php5-mail` in network `php5`
	docker run --name php5-mail --rm -d -h php5-mail \
		-l SERVICE_NAME=php5-mail \
		-p 8025:8025 \
		--network php5 \
		mailhog/mailhog

	# Step 4. Run MySQL with instance name `php5-db` and host name `php5-db` in network `php5`
	docker run --name php5-db --rm -d -h php5-db \
  		-e MYSQL_ROOT_PASSWORD=secret \
  		-e MYSQL_DATABASE=php5 \
  		-e MYSQL_USER=user \
  		-e MYSQL_PASSWORD=secret \
  		-l SERVICE_NAME=php5-db \
  		-l SERVICE_3306_NAME=php5-db \
  		-l SERVICE_33060_NAME=php5-db \
  		--health-cmd '/usr/bin/mysql --user=user --password=secret --execute "SHOW DATABASES;"' \
  		--health-interval 3s \
  		--health-retries 10 \
  		--health-start-period 3s \
  		--health-timeout 3s \
  		-p 3306:3306 \
  		--network php5 \
  		mysql:5.7 \
  		mysqld --character-set-server=utf8 --collation-server=utf8_general_ci

	# Step 5. Run Web app
	docker run --name php5-web --rm -d -h php5-web \
      -e APP_ENV=local \
      -e PHP_IDE_CONFIG='serverName=php5-web.service.docker' \
      -l SERVICE_NAME=php5-web \
      -l SERVICE_80_NAME=php5-web \
      -l SERVICE_443_NAME=php5-web \
      -p 8080:80 -p 8443:443 \
      -v "${PWD}:/home/www/app" \
      --network php5 \
      php5-web

stop:
	docker stop php5-db php5-mail php5-web

destroy:
	docker rm php5-db php5-mail php5-web
	docker network rm php5

shell:
	docker exec -it -u nginx php5-web bash

root:
	docker exec -it php5-web bash

ip:
	docker inspect php5-web | grep \"IPAddress\"