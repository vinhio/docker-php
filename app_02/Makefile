all: build run

build:
	docker-compose -f docker/docker-compose.yml build --no-cache --build-arg hostUID=1000 --build-arg hostGID=1000 web

start: run

run:
	docker-compose -f docker/docker-compose.yml -p myapp up -d web

stop:
	docker-compose -f docker/docker-compose.yml -p myapp kill

destroy:
	docker-compose -f docker/docker-compose.yml -p myapp down

logs:
	docker-compose -f docker/docker-compose.yml -p myapp logs -f web

shell:
	docker-compose -f docker/docker-compose.yml -p myapp exec --user nginx web bash

root:
	docker-compose -f docker/docker-compose.yml -p myapp exec web bash

ip:
	docker inspect myapp-web | grep \"IPAddress\"