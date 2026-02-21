# Use the official OJS image
FROM pkpofficial/ojs:3_3_0-14

# Install the missing PostgreSQL extensions for PHP
USER root
RUN apk add --no-cache php7-pgsql php7-pdo_pgsql

# Ensure the files directory is writable
RUN mkdir -p /var/www/files && chown -R apache:apache /var/www/files

USER apache

# Set environment variables for the OJS installation
ENV OJS_DB_TYPE=postgres
ENV OJS_DB_HOST=localhost
ENV OJS_DB_USER=ojs
ENV OJS_DB_PASSWORD=ojs
ENV OJS_DB_NAME=ojs

# Expose the port OJS runs on
EXPOSE 80
