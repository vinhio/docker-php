VERSION ?= 'latest'

build:
	cd docker && \
 	docker buildx build -f Dockerfile.base -t php8-base:arm64 --no-cache --platform linux/arm64 . && \
 	cd ../

run:
	docker run --platform=linux/arm64 -p 8080:80 php8-base:arm64

version:
	docker tag php8-base:arm64 vinhio/php8:arm64

push:
	docker push vinhio/php8:arm64
