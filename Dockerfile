# Use the official OJS image
FROM pkpofficial/ojs:3_3_0-14

# 1. Switch to root to perform administrative tasks
USER root

# 2. Install PostgreSQL drivers (to fix the database connection)
RUN apk add --no-cache php7-pgsql php7-pdo_pgsql

# 3. Fix the SSL Permission Error
# This grants the 'apache' user access to the SSL directory
RUN mkdir -p /etc/ssl/apache2 && \
    chown -R apache:apache /etc/ssl/apache2 && \
    chmod -R 755 /etc/ssl/apache2

# 4. Set up the uploads directory
RUN mkdir -p /var/www/files && \
    chown -R apache:apache /var/www/files && \
    chmod -R 755 /var/www/files

# 5. Switch back to the 'apache' user for security
USER apache

# Set environment variables for the OJS installation
ENV OJS_DB_TYPE=postgres
ENV OJS_DB_HOST=localhost
ENV OJS_DB_USER=ojs
ENV OJS_DB_PASSWORD=ojs
ENV OJS_DB_NAME=ojs

# Expose the port OJS runs on
EXPOSE 80
