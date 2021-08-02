#
# Another version of ../Makefile
#

# Convert docker command to docker-compose command https://www.composerize.com/


#TEST_ROOT = ../..
#include ${TEST_ROOT}/include/common.makefile
PWD = $(shell pwd)

all: build run

build:
	# Step 1: Build image
	docker build -f docker/Dockerfile.base -t php5-base docker
	# Check Web http://localhost:8080 after run below command
	#docker run -p 8080:80 php5-base
	docker build -f docker/Dockerfile.local --build-arg hostUID=1000 --build-arg hostGID=1000 -t myapp-web docker/
	# Step 2. Create network
	docker network create myapp
	#docker network inspect myapp | grep <???>
	# Step 2.1. Add container to network
	#docker network connect myapp myapp-mail
	#docker network connect myapp myapp-db
	#docker network connect myapp myapp-web

start: run

run:
	# Step 3. Run mail server with instance name `myapp-mail` and host name `myapp-mail` in network `myapp`
	docker run --name myapp-mail --rm -d -h myapp-mail \
		-l SERVICE_NAME=myapp-mail \
		-p 8025:8025 \
		--network myapp \
		mailhog/mailhog

	# Step 3.1. Run redis server with instance name `myapp-redis` and host name `myapp-redis` in network `myapp`
	docker run --name myapp-redis --rm -d -h myapp-redis \
		-l SERVICE_NAME=myapp-redis \
		--network myapp \
		redis:4.0.14-alpine3.11

	# Step 4. Run MySQL with instance name `myapp-db` and host name `myapp-db` in network `myapp`
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
  		-p 3306:3306 \
  		--network myapp \
  		mysql:5.7.35 \
  		mysqld --character-set-server=utf8 --collation-server=utf8_general_ci

	# Step 5. Run Web app
	docker run --name myapp-web --rm -d -h myapp-web \
      -e APP_ENV=local \
      -e PHP_IDE_CONFIG='serverName=myapp-web.service.docker' \
      -l SERVICE_NAME=myapp-web \
      -l SERVICE_80_NAME=myapp-web \
      -l SERVICE_443_NAME=myapp-web \
      -p 8080:80 -p 8443:443 \
      -v "${PWD}:/home/www/app" \
      --network myapp \
      myapp-web

stop:
	docker stop myapp-db myapp-mail myapp-web

destroy:
	docker rm myapp-db myapp-mail myapp-web
	docker network rm myapp

shell:
	docker exec -it -u nginx myapp-web bash

root:
	docker exec -it myapp-web bash

ip:
	docker inspect myapp-web | grep \"IPAddress\"
