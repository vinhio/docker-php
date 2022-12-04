all: build run

build:
	cd docker && \
	docker buildx build -f Dockerfile.local -t myapp-web:latest --no-cache --build-arg hostUID=1000 --build-arg hostGID=1000 --platform linux/arm64 . && \
	cd ../

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