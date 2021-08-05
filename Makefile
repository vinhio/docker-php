VERSION ?= 'latest'

build:
	docker-compose -f docker/docker-compose.yml build base

build_dev:
	docker-compose -f docker/docker-compose.yml build --no-cache base

run:
	docker run -p 8080:80 php5-base

version:
	#make version VERSION="latest"
	docker tag php5-base:latest vinhxike/php5:$(VERSION)

push:
	#make push VERSION="latest"
	docker push vinhxike/php5:$(VERSION)