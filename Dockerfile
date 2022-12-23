FROM alpine:latest

# Install packages
RUN apk --no-cache add php7.4 php7.4-fpm php7.4-mysqli php7.4-json php7.4-openssl php7.4-curl \
    php7.4-zlib php7.4-xml php7.4-intl php7.4-dom php7.4-xmlreader php7.4-ctype \
    php7.4-mbstring php7.4-gd nginx supervisor curl php7.4-imagick php7.4-redis php7.4-xdebug \
    php7.4-opcache php7.4-zip php7.4-pdo php7.4-pdo_mysql php7.4-tokenizer php7.4-fileinfo php7.4-pdo_mysql php7.4-simplexml \
    php7.4-xmlwriter php7.4-iconv composer php7.4-fileinfo tzdata

# Config PHP
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Jakarta/g" /etc/php7.4/php.ini \
    && sed -i "s/upload_max_filesize =.*/upload_max_filesize = 250M/g" /etc/php7.4/php.ini \
    && sed -i "s/memory_limit = 128M/memory_limit = 512M/g" /etc/php7.4/php.ini \
    && sed -i "s/post_max_size =.*/post_max_size = 250M/g" /etc/php7.4/php.ini \
    && sed -i "s/user = nobody/user = root/g" /etc/php7.4/php-fpm.d/www.conf \
    && sed -i "s/group = nobody/group = root/g" /etc/php7.4/php-fpm.d/www.conf \
    && sed -i "s/listen.owner = nobody/listen.owner = root/g" /etc/php7.4/php-fpm.d/www.conf \
    && sed -i "s/listen.group = nobody/listen.group = root/g" /etc/php7.4/php-fpm.d/www.conf \
    && sed -i "s/listen.group = nobody/listen.group = root/g" /etc/php7.4/php-fpm.d/www.conf \
    && cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && echo Asia/Jakarta > /etc/timezone \
    && apk del tzdata

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy nginx config
COPY server/nginx.conf /etc/nginx/nginx.conf
COPY server/upstream.conf /etc/nginx/upstream.conf

# Configure PHP-FPM
COPY server/fpm-pool.conf /etc/php7.4/php-fpm.d/my_custom.conf

# Configure supervisord
COPY server/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 443
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
