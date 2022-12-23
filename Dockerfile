FROM php:7.4-fpm-alpine

# Install dependencies
RUN apk add --no-cache \
    curl \
    git \
    unzip \
    libzip-dev \
    libonig-dev \
    postgresql-dev \
    && docker-php-ext-install pdo_pgsql zip mbstring exif pcntl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create app directory and set as working directory
RUN mkdir /var/www/app
WORKDIR /var/www/app

# Copy app source code
COPY . /var/www/app

# Install app dependencies
RUN composer install

# Copy PHP-FPM configuration
COPY config/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

# Copy NGINX configuration
COPY config/nginx/app.conf /etc/nginx/conf.d/default.conf

# Expose app port
EXPOSE 80

# Set entrypoint
ENTRYPOINT ["nginx", "-g", "daemon off;"]