FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev \
    libpq-dev \
    git \
    curl

# Install PHP extensions
RUN docker-php-ext-install zip pdo pdo_pgsql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy Laravel project files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Generate key (will be overridden in Render with env var)
RUN php artisan key:generate --force

# Set Laravel permissions
RUN chmod -R 755 storage bootstrap/cache

# Expose port
EXPOSE 8000

# Run Laravel's development server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
