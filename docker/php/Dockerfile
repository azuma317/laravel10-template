FROM composer:2.5 as vendor

COPY database/ database/

COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

FROM node:18.16 as frontend

RUN mkdir -p /app/public

COPY package.json package-lock.json vite.config.js /app/
COPY resources/css/ /app/resources/css/
COPY resources/js/ /app/resources/js/

WORKDIR /app

RUN npm ci && npm run build

FROM php:8.2-apache as backend

RUN apt-get update \
  && apt-get install -y zlib1g-dev mariadb-client vim libzip-dev \
  && docker-php-ext-install zip pdo_mysql

COPY docker/apache/apache2.conf /etc/apache2/apache2.conf
COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

COPY docker/php/php.ini /usr/local/etc/php/php.ini

COPY . /var/www/html
COPY --from=vendor /app/vendor/ /var/www/html/vendor/
COPY --from=frontend /app/public/build/ /var/www/html/public/build/
COPY --from=frontend /app/node_modules /var/www/html/node_modules/

RUN chown -R www-data:www-data /var/www/html/storage \
  && chown -R www-data:www-data /var/www/html/bootstrap/cache

WORKDIR /var/www/html