Docker image vinhio/php8 installed xdebug
        - /usr/local/lib/php/extensions/no-debug-non-zts-20210902/xdebug.so
        - /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    But ini file was removed. Check file docker/Dockerfile.base

So to use XDebug at local. Just mapping in docker-compose.yml file:
    web:
    ....
        extra_hosts:
            - "host.docker.internal:host-gateway"
    ....
    ....
    volumes:
      # Override xdebug.ini of image `vinhio/php8`
      - ./customize/usr/local/etc/php/conf.d/xdebug.ini:/usr/local/etc/php/conf.d/xdebug.ini
    ....
