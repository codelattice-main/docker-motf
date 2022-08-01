FROM composer:2.1.3

WORKDIR /var/www/html

RUN composer require laravel/envoy --dev

RUN composer require predis/predis

