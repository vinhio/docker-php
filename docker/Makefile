all: build run

build:
	docker-compose -f docker/docker-compose.yml build base
	#docker-compose -f docker/docker-compose.yml build --no-cache --build-arg hostUID=`id -u` --build-arg hostGID=`id -g` web
	docker-compose -f docker/docker-compose.yml build --no-cache --build-arg hostUID=1000 --build-arg hostGID=1000 web

start: run

run:
	docker-compose -f docker/docker-compose.yml -p php5 up -d web

stop:
	docker-compose -f docker/docker-compose.yml -p php5 kill

destroy:
	docker-compose -f docker/docker-compose.yml -p php5 down

logs:
	docker-compose -f docker/docker-compose.yml -p php5 logs -f web

shell:
	docker-compose -f docker/docker-compose.yml -p ygm exec --user nginx web bash

root:
	docker-compose -f docker/docker-compose.yml -p ygm exec web bash

ip:
	docker inspect php5-web | grep \"IPAddress\"
