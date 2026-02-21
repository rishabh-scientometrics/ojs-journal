# 1. Use the stable OJS 3.5 image
FROM pkpofficial/ojs:3_5_0-3

USER root

# 2. Install ALL required libraries and PHP extensions for OJS 3.5
# Added: libicu-dev (for intl) and libzip-dev (for zip)
RUN apt-get update && apt-get install -y \
    libpq-dev libpng-dev libxml2-dev libzip-dev libonig-dev libicu-dev openssl \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring xml intl zip gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Fix SSL and Permissions
RUN mkdir -p /etc/ssl/apache2 && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/apache2/server.key \
    -out /etc/ssl/apache2/server.pem \
    -subj "/CN=localhost" \
    -addext "basicConstraints=CA:FALSE"

# 4. Critical: Ensure all OJS directories are writable by the Ubuntu user (www-data)
RUN mkdir -p /var/www/files /var/www/logs && \
    chown -R www-data:www-data /var/www/html /var/www/files /var/www/logs && \
    chmod -R 777 /var/www/files /var/www/logs /var/www/html/cache /var/www/html/public

# 5. DEBUG MODE: This will force OJS to show the error on the screen instead of a blank page
RUN sed -i 's/display_errors = Off/display_errors = On/' /var/www/html/config.template.inc.php

ENV HTTPS=on
EXPOSE 80
