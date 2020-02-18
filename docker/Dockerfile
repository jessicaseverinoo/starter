FROM php:7.4-apache-buster

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_OPCACHE_MAX_ACCELERATED_FILES=20000 \
    PHP_OPCACHE_MEMORY_CONSUMPTION=128

# atualiza o sistema
RUN apt-get -yqq update

# pacotes basicos
RUN apt-get -yqq --no-install-recommends install apt-utils nano

# timezone e locale
RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN apt-get -yqq --no-install-recommends install locales
RUN sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen
ENV LANG pt_BR.UTF-8
ENV LANGUAGE pt_BR.UTF-8
ENV LC_ALL pt_BR.UTF-8

#zip
RUN apt-get -yqq --no-install-recommends install libzip-dev zip
RUN docker-php-ext-install zip

# gd
RUN apt-get -yqq --no-install-recommends install libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev pkg-config
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd

# install imagick
RUN apt-get -yqq --no-install-recommends install libmagickwand-dev
RUN pecl install imagick
RUN docker-php-ext-enable imagick

# exif
RUN docker-php-ext-install exif

# intl
RUN apt-get -yqq --no-install-recommends install libicu-dev
RUN docker-php-ext-install intl

# supervisord
RUN apt-get -yqq --no-install-recommends install supervisor
COPY docker/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

# opcache
RUN docker-php-ext-install opcache

# pdo (mysql)
RUN docker-php-ext-install pdo pdo_mysql

# redis
RUN pecl install redis \
    && docker-php-ext-enable redis

# apache
RUN a2enmod rewrite negotiation

# aplica as configurações do host
COPY docker/bash/.bashrc /root/.bashrc
COPY docker/php/conf.d/*.ini /usr/local/etc/php/conf.d/
COPY docker/php/php.ini /usr/local/etc/php/
COPY docker/apache/vhost.conf /etc/apache2/sites-available/000-default.conf

# composer
COPY docker/php/composer-installer.sh /usr/local/bin/composer-installer
RUN chmod +x /usr/local/bin/composer-installer \
    && /usr/local/bin/composer-installer \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer --version

# copia os arquivos
COPY . /var/www/html

# instala as dependencias
#RUN composer install \
#    --no-interaction \
#    --no-plugins \
#    --no-scripts \
#    --prefer-dist

# permissões
#RUN chmod -R 775 /var/www/html/storage \
#    && chmod -R 775 /var/www/html/bootstrap/cache \
#    && chown -R www-data:www-data /var/www/html

# inicia a aplicacao
COPY docker/run-app.sh /usr/local/bin/run-app
RUN chmod +x /usr/local/bin/run-app

CMD ["/usr/local/bin/run-app"]
