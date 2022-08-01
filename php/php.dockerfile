FROM php:8.0-fpm

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

RUN sed -i "s/user = www-data/user = root/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = root/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions

RUN apt-get install -y vim 

RUN apt-get update -y

RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/php-opocache-cfg.ini



RUN DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
      curl \
      git \
      zip unzip \
# iconv, mbstring and pdo_sqlite are omitted as they are already installed
    && PHP_EXTENSIONS=" \
      bcmath \
      bz2 \
      calendar \
      exif \
      gd \
      intl \
      ldap \
      memcached \
      mysqli \
      opcache \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      redis \
      soap \
      sockets \
      xsl \
      zip \
      pcntl \
    " \
    && case "$PHP_VERSION" in \
      5.6.*) PHP_EXTENSIONS="$PHP_EXTENSIONS mcrypt mysql";; \
      7.0.*|7.1.*) PHP_EXTENSIONS="$PHP_EXTENSIONS mcrypt";; \
    esac \
    && install-php-extensions $PHP_EXTENSIONS \
    && if command -v a2enmod; then a2enmod rewrite; fi

RUN apt-get update 

RUN apt-get install -y wget 

RUN apt-get -y install procps 

RUN wget https://getcomposer.org/composer-stable.phar -O /usr/local/bin/composer && chmod +x /usr/local/bin/composer

COPY ./id_rsa /root/.ssh/ 

RUN chmod 0400 /root/.ssh/id_rsa 

RUN ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts 

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
