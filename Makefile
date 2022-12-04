VERSION ?= 'latest'

build:
	cd docker && \
	docker buildx build -f Dockerfile.base -t php5-base:arm64 --no-cache --platform linux/arm64 . && \
	cd ../

run:
	docker run --platform=linux/arm64 -p 8080:80 php5-base:arm64

version:
	docker tag php5-base:arm64 vinhio/php5:arm64

push:
	docker push vinhio/php5:arm64
