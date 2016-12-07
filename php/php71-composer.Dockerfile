FROM php:7.1-fpm
MAINTAINER Mikhail Chervontsev <m.a.chervontsev@gmail.com>

ENV COMPOSER_HOME /root/composer
ENV COMPOSER_VERSION master
ENV PATH $COMPOSER_HOME/vendor/bin:$PATH

RUN apt-get update -qqq \
    && apt-get install -y -qqq  \
                    unzip \
                    libaio1 \
                    libxml2-dev \
                    libaio-dev \
                    libfreetype6-dev \
                    libjpeg62-turbo-dev \
                    libpng12-dev \
                    strace \
                    git \
                    vim \
    && pecl install xdebug \
    && docker-php-ext-install gd \
    && docker-php-ext-install soap \
    && docker-php-ext-install zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require hirak/prestissimo  \
    && composer global require phpunit/phpunit  \
    && composer global require phpspec/phpspec  \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false unzip libaio-dev libxml2-dev  \
    && apt-get clean -y \
    && rm /tmp -r \
    && mkdir -p /app/web \
    && chown www-data:www-data -R /app

COPY ./config/xdebug.ini /usr/local/etc/php/conf.d/30-xdebug.ini
COPY ./config/php.ini /usr/local/etc/php/php.ini
COPY ./config/fpm/php-fpm.conf /usr/local/etc/
COPY ./config/fpm/pool.d /usr/local/etc/pool.d

VOLUME /app
WORKDIR /app
