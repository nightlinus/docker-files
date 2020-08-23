FROM php:7.4-fpm
MAINTAINER Mikhail Chervontsev <m.a.chervontsev@gmail.com>

# Oracle instantclient
COPY ./instantclient/instantclient-basiclite-linux.x64-19.6.0.0.0.zip /tmp/instantclient.zip
COPY ./instantclient/instantclient-sdk-linux.x64-19.6.0.0.0.zip /tmp/sdk.zip

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
ENV PATH $COMPOSER_HOME/vendor/bin:$PATH
ENV LIQUIBASE_VERSION 3.10.2
ENV LIQUIBASE_DRIVER_PATH /usr/local/jdbc/ojdbc8.jar
ENV HOME /home/www-data

RUN apt-get update -qqq \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/client/linux_static/amd64 | tar zxp -C /tmp \
    && mv /tmp/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire \
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
    && rm -R /usr/share/man/man1 \
    && unzip /tmp/instantclient.zip -d /usr/local/ \
    && unzip /tmp/sdk.zip -d /usr/local/ \
    && ln -s /usr/local/instantclient* /usr/local/instantclient \
    && echo '/usr/local/instantclient' > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig \
    && echo 'instantclient,/usr/local/instantclient' | pecl install oci8 \
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
    && docker-php-ext-install exif \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require phpspec/phpspec  \
    && composer global require phpunit/phpunit  \
    && composer global require brianium/paratest \
    && composer global require psy/psysh \
    && curl -A "Docker" -o /tmp/liquibase.tar.gz -D - -L -s "https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz" \
    && mkdir -p /opt/liquibase \
    && tar -xzf /tmp/liquibase.tar.gz -C /opt/liquibase \
    && rm -f /tmp/liquibase.tar.gz \
    && chmod +x /opt/liquibase/liquibase \
    && ln -s /opt/liquibase/liquibase /usr/local/bin/ \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false unzip libaio-dev libxml2-dev libldap2-dev \
    && apt-get clean -y \
    && rm /tmp -r \
    && mkdir -p /app/web \
    && chown www-data:www-data -R /app \
    && mkdir -p "${HOME}" \
    && chown www-data:www-data -R "${HOME}" \
    && chmod ag+rwx -R "${HOME}" \
    && chmod a+rwx -R /composer

COPY ./config/oci8.ini /usr/local/etc/php/conf.d/30-oci8.ini
COPY ./config/opcache.ini /usr/local/etc/php/conf.d/30-opcache.ini
COPY ./config/php.ini /usr/local/etc/php/php.ini
COPY ./config/fpm/php-fpm.conf /usr/local/etc/
COPY ./config/fpm/pool.d/www73.conf /usr/local/etc/pool.d/www73.conf

USER 1000

VOLUME /app
WORKDIR /app
