VERSION ?= 'latest'

build:
	docker-compose -f docker/docker-compose.yml build --no-cache base

run:
	docker run -p 8080:80 php7-base

version:
	#make version VERSION="latest"
	docker tag php7-base:latest vinhxike/php7:$(VERSION)

push:
	#make push VERSION="latest"
	docker push vinhxike/php7:$(VERSION)
