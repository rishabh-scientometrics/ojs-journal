FROM pkpofficial/ojs:3_5_0-3
USER root

# Install required PHP extensions and postgresql-client
RUN apt-get update && apt-get install -y \
    libpq-dev libpng-dev libxml2-dev libzip-dev libonig-dev libicu-dev openssl postgresql-client \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring xml intl zip gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# SSL certificate
RUN mkdir -p /etc/ssl/apache2 && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/apache2/server.key \
    -out /etc/ssl/apache2/server.pem \
    -subj "/CN=localhost" \
    -addext "basicConstraints=CA:FALSE"

# Generate config.inc.php from template
RUN if [ -f /var/www/html/config.TEMPLATE.inc.php ]; then \
    cp /var/www/html/config.TEMPLATE.inc.php /var/www/html/config.inc.php; \
    fi

# Enable error display for debugging
RUN sed -i 's/display_errors = Off/display_errors = On/' /var/www/html/config.inc.php

# Set permissions
RUN mkdir -p /var/www/files /var/www/logs && \
    chown -R www-data:www-data /var/www/html /var/www/files /var/www/logs && \
    chmod -R 777 /var/www/files /var/www/logs /var/www/html/cache /var/www/html/public

# Copy and set entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
