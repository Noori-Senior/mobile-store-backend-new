# Use official PHP 8.2 CLI image
FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev \
    libpq-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install zip pdo pdo_pgsql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy all project files
COPY . .

# Copy example env to .env for artisan commands during build
RUN cp .env.example .env

# Install PHP dependencies without dev packages and optimize autoloader
RUN composer install --no-dev --optimize-autoloader

# Generate Laravel app key
RUN php artisan key:generate --force

# Clear and cache config (optional but recommended)
RUN php artisan config:clear
RUN php artisan config:cache

# Set permissions for storage and cache
RUN chmod -R 755 storage bootstrap/cache

# Expose port 8000 (Laravel's default dev server port)
EXPOSE 8000

# Run Laravel dev server (Render will override this with its own start command)
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
