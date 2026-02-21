# Update the version to 3.4.0-8 (or the latest stable)
FROM pkpofficial/ojs:3_4_0-8

USER root

# IMPORTANT: Newer OJS images use PHP 8.1 or 8.2. 
# We update the 'apk add' to use the correct version for this image.
RUN apk add --no-cache php81-pgsql php81-pdo_pgsql

# Keep the permission fixes
RUN mkdir -p /var/www/files /var/www/logs /etc/ssl/apache2 && \
    chown -R apache:apache /var/www/files /var/www/logs /etc/ssl/apache2 && \
    chmod -R 777 /var/www/files /var/www/logs /etc/ssl/apache2

ENV HTTPS=on

EXPOSE 80
