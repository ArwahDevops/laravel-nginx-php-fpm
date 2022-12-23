FROM php:7.4-fpm-alpine

# Install dependencies
RUN apk add --no-cache \
    curl-dev \
    git \
    unzip \
    libzip-dev \
#    libonig-dev \
    libxml2-dev \
    libpng-dev \
    postgresql-dev \
    oniguruma-dev \
    && docker-php-ext-install gd pdo pdo_mysql pdo_pgsql zip mbstring exif pcntl curl xml bcmath json

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
COPY server/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

# Copy NGINX configuration
COPY server/nginx/app.conf /etc/nginx/conf.d/default.conf

# Expose app port
EXPOSE 80

# Set entrypoint
ENTRYPOINT ["nginx", "-g", "daemon off;"]