FROM php:8.0-rc-fpm
MAINTAINER Mikhail Chervontsev <m.a.chervontsev@gmail.com>

# Oracle instantclient
COPY ./instantclient/instantclient-basiclite-linux.x64-19.9.0.0.0.zip /tmp/instantclient.zip
COPY ./instantclient/instantclient-sdk-linux.x64-19.9.0.0.0.zip /tmp/sdk.zip

# Install jdbc for liquibase
COPY ./jdbc/ojdbc8.jar /usr/local/jdbc/ojdbc8.jar

ENV NLS_LANG RUSSIAN_AMERICA.AL32UTF8
ENV NLS_SORT RUSSIAN
ENV NLS_DATE_LANGUAGE AMERICAN
ENV NLS_LANGUAGE RUSSIAN
ENV NLS_CALENDAR GREGORIAN
ENV NLS_DATE_FORMAT YYYY-MM-DD HH24:MI:SS
ENV COMPOSER_HOME /composer
ENV COMPOSER_VERSION master
ENV PATH $COMPOSER_HOME/vendor/bin:/opt/phpspy:$PATH
ENV LIQUIBASE_VERSION 3.10.3
ENV LIQUIBASE_DRIVER_PATH /usr/local/jdbc/ojdbc8.jar
ENV HOME /home/www-data

RUN apt-get update -qqq \
    && mkdir -p /usr/share/man/man1 \
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
                    default-jre \
                    unzip \
                    strace \
                    vim \
                    git \
                    python \
                    less \
                    openssh-client \
                    net-tools \
                    wget \
                    gdb \
    && rm -R /usr/share/man/man1 \
    && unzip /tmp/instantclient.zip -d /usr/local/ \
    && unzip /tmp/sdk.zip -d /usr/local/ \
    && wget https://github.com/FriendsOfPHP/pickle/releases/download/v0.6.0/pickle.phar \
    && mv pickle.phar /usr/local/bin/pickle \
    && chmod +x /usr/local/bin/pickle \
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
    && docker-php-ext-install calendar \
    && docker-php-ext-install opcache \
    && docker-php-ext-install exif \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && ln -s /usr/local/instantclient* /usr/local/instantclient \
    && echo '/usr/local/instantclient' > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig \
    && docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient \
    && docker-php-ext-install oci8 \
    && git clone --depth 1 https://github.com/xdebug/xdebug.git /usr/src/php/ext/xdebug \
    && docker-php-ext-configure xdebug --enable-xdebug-dev \
    && docker-php-ext-install xdebug \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require phpspec/phpspec  \
    && composer global require phpunit/phpunit  \
    #&& composer global require brianium/paratest \
    && composer global require psy/psysh \
    && curl -A "Docker" -o /tmp/liquibase.tar.gz -D - -L -s "https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz" \
    && mkdir -p /opt/liquibase \
    && tar -xzf /tmp/liquibase.tar.gz -C /opt/liquibase \
    && rm -f /tmp/liquibase.tar.gz \
    && chmod +x /opt/liquibase/liquibase \
    && ln -s /opt/liquibase/liquibase /usr/local/bin/ \
    && git clone https://github.com/adsr/phpspy.git /opt/phpspy \
    && cd /opt/phpspy \
    && make \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false libaio-dev unzip python libxml2-dev libldap2-dev wget  \
    && apt-get clean -y \
    && rm -rfv "/tmp/*" \
    && mkdir -p /app/web \
    && chown www-data:www-data -R /app \
    && mkdir -p "${HOME}" \
    && chown www-data:www-data -R "${HOME}" \
    && chmod ag+rwx -R "${HOME}" \
    && git config --global core.safecrlf false \
    && chmod a+rwx -R /composer \
    && rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && rm /usr/local/etc/php/conf.d/docker-php-ext-oci8.ini

COPY ./config/oci8.ini /usr/local/etc/php/conf.d/30-oci8.ini
#COPY ./config/xdebug.ini /usr/local/etc/php/conf.d/30-xdebug.ini
COPY ./config/opcache.ini /usr/local/etc/php/conf.d/30-opcache.ini
COPY ./config/php.ini /usr/local/etc/php/php.ini
COPY ./config/fpm/php-fpm.conf /usr/local/etc/
COPY ./config/fpm/pool.d/www73.conf /usr/local/etc/pool.d/www73.conf

USER 1000

VOLUME /app
WORKDIR /app
