#!/usr/bin/with-contenv bash

source /root/.bashrc
echo -e "${BLUE}--- Install composer dependencies ---${NC}"

COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_MEMORY_LIMIT=-1 php /usr/local/bin/composer install --prefer-dist --no-interaction --optimize-autoloader --no-progress --no-suggest
