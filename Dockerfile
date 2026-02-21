# Use the latest stable OJS 3.5 image
FROM pkpofficial/ojs:3_5_0-3

# 1. Switch to root for configuration
USER root

# 2. Install PostgreSQL drivers for PHP 8.3 (Required for OJS 3.5)
RUN apk add --no-cache php83-pgsql php83-pdo_pgsql

# 3. Maintain directory permissions for Render
RUN mkdir -p /var/www/files /var/www/logs /etc/ssl/apache2 && \
    chown -R apache:apache /var/www/files /var/www/logs /etc/ssl/apache2 && \
    chmod -R 777 /var/www/files /var/www/logs /etc/ssl/apache2

# 4. Set environment variable for Render's HTTPS
ENV HTTPS=on

# 5. Expose port 80
EXPOSE 80
