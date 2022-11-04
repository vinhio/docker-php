VERSION ?= 'latest'

build:
	cd docker && docker buildx build -f Dockerfile.base -t php7-base:latest --no-cache --platform linux/arm64 . && cd ../

run:
	docker run --platform=linux/arm64 -p 8080:80 php7-base

version:
	#make version VERSION="arm64"
	#make version VERSION="latest"
	docker tag php7-base:latest vinhio/php7:$(VERSION)

push:
	#make push VERSION="arm64"
	#make push VERSION="latest"
	docker push vinhio/php7:$(VERSION)
