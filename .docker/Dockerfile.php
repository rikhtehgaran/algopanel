FROM php:8.2-fpm

# Install system dependencies & PHP extensions needed by ISPConfig interface
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libzip-dev \
        libxml2-dev \
        libcurl4-openssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        mysqli \
        gd \
        curl \
        simplexml \
        xml \
        zip \
        opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create ISPConfig directories and permissions
RUN mkdir -p /var/log/ispconfig /usr/local/ispconfig \
    && chown -R www-data:www-data /var/log/ispconfig

COPY php.ini /usr/local/etc/php/conf.d/ispconfig.ini

WORKDIR /usr/local/ispconfig
