FROM nightlinus/hermes:7.0-fpm
MAINTAINER Mikhail Chervontsev <m.a.chervontsev@gmail.com>

COPY ./config/xdebug.ini /usr/local/etc/php/conf.d/30-xdebug.ini
