FROM php:7.4-cli
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
                    libldap2-dev \
                    libzip4 \
                    libzip-dev \
    && docker-php-ext-install gd \
    && docker-php-ext-install soap \
    && docker-php-ext-install zip \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install intl \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install opcache \
    && docker-php-ext-install calendar \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require brianium/paratest \
    && composer global require hirak/prestissimo  \
    && composer global require phpspec/phpspec  \
    && composer global require phpunit/phpunit  \
    && composer global require squizlabs/php_codesniffer \
    && composer global require psy/psysh \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false unzip libaio-dev libxml2-dev libldap2-dev \
    && apt-get clean -y \
    && rm /tmp -r \
    && mkdir -p /app/web \
    && chown www-data:www-data -R /app \
    && chmod a+rwx -R /composer

USER 1000

VOLUME /app
WORKDIR /app
