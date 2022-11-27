VERSION ?= 'latest'

build:
	cd docker && \
	docker buildx build -f Dockerfile.base -t php7-base:arm64 --no-cache --platform linux/arm64 . && \
	cd ../

run:
	docker run --platform=linux/arm64 -p 8080:80 php7-base:arm64

version:
	docker tag php7-base:arm64 vinhio/php7:arm64

push:
	docker push vinhio/php7:arm64
