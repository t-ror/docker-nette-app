# Use the official PHP image with PHP 8.2 and FPM
FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libpq-dev \
    nginx \
    supervisor

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo pdo_pgsql pgsql mbstring zip exif pcntl gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Ensure the run directory exists and has the correct permissions
RUN mkdir -p /var/run/php && chown www-data:www-data /var/run/php

# Copy PHP-FPM configuration file
COPY /config/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Copy Nginx configuration file
COPY /config/nginx.conf /etc/nginx/nginx.conf

# Copy Supervisor configuration file
COPY /config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /var/www

# Copy project files
COPY .. .

# Expose port 80
EXPOSE 80

# Start Supervisor
CMD ["/usr/bin/supervisord"]