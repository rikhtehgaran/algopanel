FROM php:8.2-apache

RUN docker-php-ext-install mysqli \
    && a2enmod rewrite headers \
    && mkdir -p /var/log/ispconfig /usr/local/ispconfig \
    && chown -R www-data:www-data /var/log/ispconfig \
    && ln -sf /usr/local/ispconfig/interface/web /var/www/ispconfig

COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY php.ini /usr/local/etc/php/conf.d/ispconfig.ini

WORKDIR /usr/local/ispconfig
