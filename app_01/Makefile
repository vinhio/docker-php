all: run

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