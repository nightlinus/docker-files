FROM php:8.0-cli
MAINTAINER Mikhail Chervontsev <m.a.chervontsev@gmail.com>

ENV COMPOSER_HOME /composer
ENV COMPOSER_VERSION master
ENV PATH $COMPOSER_HOME/vendor/bin:$PATH
ENV HOME /home/composer

RUN apt-get update -qqq \
    && apt-get install -y -qqq  \
                    libaio1 \
                    libaio-dev \
                    libxml2 \
                    libxml2-dev \
                    libfreetype6 \
                    libfreetype6-dev \
                    libjpeg62-turbo \
                    libjpeg62-turbo-dev \
                    libpng-dev \
                    libzip4 \
                    libzip-dev \
                    libbz2-1.0 \
                    libbz2-dev \
                    libldap2-dev \
                    unzip \
                    strace \
                    vim \
                    git \
                    python \
                    less \
                    net-tools \
    && docker-php-ext-configure gd \
       --with-jpeg=/usr/include/   \
       --with-freetype=/usr/include/ \
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
    && composer global require phpspec/phpspec  \
    && composer global require phpunit/phpunit  \
    && composer global require brianium/paratest \
    && composer global require squizlabs/php_codesniffer \
    && composer global require psy/psysh \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false unzip libaio-dev libxml2-dev libldap2-dev \
    && apt-get clean -y \
    && rm -rf "/tmp/*" \
    && mkdir -p /app/web \
    && chown www-data:www-data -R /app \
    && mkdir -p "${HOME}" \
    && chown www-data:www-data -R "${HOME}" \
    && chmod ag+rwx -R "${HOME}" \
    && git config --global core.safecrlf false \
    && chmod a+rwx -R /composer

USER 1000

VOLUME /app
WORKDIR /app
