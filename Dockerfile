# Use the official OJS image
FROM pkpofficial/ojs:3_3_0-14

# 1. Switch to root to fix permissions and install drivers
USER root

# 2. Install PostgreSQL drivers (This fixes the [ PostgreSQL ] brackets)
RUN apk add --no-cache php7-pgsql php7-pdo_pgsql

# 3. Create necessary directories and set correct permissions
RUN mkdir -p /var/www/files /var/www/logs /etc/ssl/apache2 && \
    chown -R apache:apache /var/www/files /var/www/logs /etc/ssl/apache2 && \
    chmod -R 777 /var/www/files /var/www/logs /etc/ssl/apache2

# 4. Fix internal script errors
ENV HTTPS=on

# 5. Expose the port (Keep this one)
EXPOSE 80

# We do NOT add "USER apache" here so the startup script can run as root
