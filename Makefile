VERSION ?= 'latest'

build:
	docker-compose -f docker/docker-compose.yml build --no-cache base

run:
	docker run -p 8080:80 php5-base

version:
	#make version VERSION="latest"
	docker tag php5-base:latest vinhio/php5:$(VERSION)

push:
	#make push VERSION="latest"
	docker push vinhio/php5:$(VERSION)