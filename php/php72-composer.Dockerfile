FROM php:7.2-fpm
MAINTAINER Mikhail Chervontsev <m.a.chervontsev@gmail.com>

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
                    strace \
                    git \
                    vim \
                    libbz2-1.0 \
                    libbz2-dev \
    && docker-php-ext-install gd \
    && docker-php-ext-install soap \
    && docker-php-ext-install zip \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install intl \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install calendar \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require hirak/prestissimo  \
    && composer global require phpspec/phpspec  \
    && composer global require phpunit/phpunit  \
    && composer global require squizlabs/php_codesniffer \
    && composer global require psy/psysh \
    && composer global require brianium/paratest \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false unzip libaio-dev libxml2-dev  \
    && apt-get clean -y \
    && rm /tmp -r \
    && mkdir -p /app/web \
    && chown www-data:www-data -R /app \
    && chmod a+rwx -R /composer

COPY ./config/php.ini /usr/local/etc/php/php.ini
COPY ./config/fpm/php-fpm.conf /usr/local/etc/
COPY ./config/fpm/pool.d /usr/local/etc/pool.d

USER 1000

VOLUME /app
WORKDIR /app
