FROM php:7.4-fpm-alpine

# Add repos
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Add basics first
RUN apk update && apk upgrade && apk add \
	bash curl ca-certificates git nano libxml2-dev tzdata icu-dev openntpd libedit-dev libzip-dev \
        supervisor aspell-libs aspell-dev autoconf gcc g++ make

RUN docker-php-ext-install gd pdo pdo_pgsql pspell zip pcntl sockets intl exif simplexml soap xml curl mbstring

# install redis
RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  docker-php-ext-enable redis

# Add Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

RUN apk add nginx npm
COPY gumasev/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY gumasev/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY gumasev/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY gumasev/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create app directory and set as working directory
RUN mkdir -p /var/www
WORKDIR /var/www

# Copy app source code
COPY . /var/www

# Install app dependencies
RUN composer install

# Expose the port nginx is reachable on
EXPOSE 8080 9000

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
#HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
