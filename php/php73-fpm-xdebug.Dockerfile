FROM php:7.3-fpm
MAINTAINER Mikhail Chervontsev <m.a.chervontsev@gmail.com>

# Oracle instantclient
COPY ./instantclient/instantclient-basiclite-linux.x64-18.3.0.0.0.zip /tmp/instantclient.zip
COPY ./instantclient/instantclient-sdk-linux.x64-18.3.0.0.0.zip /tmp/sdk.zip

ENV NLS_LANG RUSSIAN_AMERICA.AL32UTF8
ENV NLS_SORT RUSSIAN
ENV NLS_DATE_LANGUAGE AMERICAN
ENV NLS_LANGUAGE RUSSIAN
ENV NLS_CALENDAR GREGORIAN
ENV NLS_DATE_FORMAT YYYY-MM-DD HH24:MI:SS
ENV COMPOSER_HOME /composer
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
                    libpng-dev \
                    strace \
                    vim \
                    less \
                    libzip4 \
                    libzip-dev \
                    net-tools \
                    libbz2-1.0 \
                    libbz2-dev \
                    libldap2-dev \
    && unzip /tmp/instantclient.zip -d /usr/local/ \
    && unzip /tmp/sdk.zip -d /usr/local/ \
    && ln -s /usr/local/instantclient_18_3 /usr/local/instantclient \
    && echo '/usr/local/instantclient' > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig \
    && echo 'instantclient,/usr/local/instantclient' | pecl install oci8 \
    && pecl install xdebug-2.7.0beta1 \
    && docker-php-ext-install gd \
    && docker-php-ext-install soap \
    && docker-php-ext-install zip \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install intl \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install calendar \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require phpspec/phpspec  \
    && composer global require phpunit/phpunit  \
    && composer global require psy/psysh \
    && composer global require brianium/paratest \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false unzip libaio-dev libxml2-dev libldap2-dev  \
    && apt-get clean -y \
    && rm /tmp -r \
    && mkdir -p /app/web \
    && chown www-data:www-data -R /app \
    && chmod a+rwx -R /composer

COPY ./config/oci8.ini /usr/local/etc/php/conf.d/30-oci8.ini
COPY ./config/xdebug.ini /usr/local/etc/php/conf.d/30-xdebug.ini
COPY ./config/php.ini /usr/local/etc/php/php.ini
COPY ./config/fpm/php-fpm.conf /usr/local/etc/
COPY ./config/fpm/pool.d/www73.conf /usr/local/etc/pool.d/www73.conf

USER 1000

VOLUME /app
WORKDIR /app
