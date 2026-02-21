# 1. Use the official stable OJS 3.5 image
FROM pkpofficial/ojs:3_5_0-3

USER root

# 2. Install essential libraries and PostgreSQL drivers for Ubuntu
RUN apt-get update && apt-get install -y \
    libpq-dev libpng-dev libxml2-dev libzip-dev libonig-dev libicu-dev openssl \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring xml intl zip gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Fix SSL warnings (required for Render's internal connection)
RUN mkdir -p /etc/ssl/apache2 && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/apache2/server.key \
    -out /etc/ssl/apache2/server.pem \
    -subj "/CN=localhost" \
    -addext "basicConstraints=CA:FALSE"

# 4. Set directory permissions for the web server
RUN mkdir -p /var/www/files /var/www/logs && \
    chown -R www-data:www-data /var/www/html /var/www/files /var/www/logs && \
    chmod -R 777 /var/www/files /var/www/logs

# 5. Environment settings
ENV HTTPS=on
EXPOSE 80

# Keep as root so the startup script can launch services
