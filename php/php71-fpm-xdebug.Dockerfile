FROM php:7.1-fpm
MAINTAINER Mikhail Chervontsev <m.a.chervontsev@gmail.com>

# Oracle instantclient
COPY ./instantclient/instantclient-basiclite-linux.x64-12.1.0.2.0.zip /tmp/instantclient.zip
COPY ./instantclient/instantclient-sdk-linux.x64-12.1.0.2.0.zip /tmp/sdk.zip

ENV NLS_LANG RUSSIAN_AMERICA.AL32UTF8
ENV NLS_SORT RUSSIAN
ENV NLS_DATE_LANGUAGE AMERICAN
ENV NLS_LANGUAGE RUSSIAN
ENV NLS_CALENDAR GREGORIAN
ENV NLS_DATE_FORMAT YYYY-MM-DD HH24:MI:SS

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
                    vim \
                    less \
                    net-tools \
    && unzip /tmp/instantclient.zip -d /usr/local/ \
    && unzip /tmp/sdk.zip -d /usr/local/ \
    && ln -s /usr/local/instantclient_12_1 /usr/local/instantclient \
    && ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so \
    && ldconfig \
    && echo 'instantclient,/usr/local/instantclient' | pecl install oci8 \
    && pecl install xdebug \
    && docker-php-ext-install gd \
    && docker-php-ext-install soap \
    && docker-php-ext-install zip \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false unzip libaio-dev libxml2-dev  \
    && apt-get clean -y \
    && rm /tmp -r \
    && mkdir -p /app/web \
    && chown www-data:www-data -R /app

COPY ./config/oci8.ini /usr/local/etc/php/conf.d/30-oci8.ini
COPY ./config/xdebug.ini /usr/local/etc/php/conf.d/30-xdebug.ini
COPY ./config/php.ini /usr/local/etc/php/php.ini
COPY ./config/fpm/php-fpm.conf /usr/local/etc/
COPY ./config/fpm/pool.d /usr/local/etc/pool.d

VOLUME /app
WORKDIR /app
