# Use the latest stable OJS 3.5 image
FROM pkpofficial/ojs:3_5_0-3

# 1. Switch to root to install drivers
USER root

# 2. Update and install PostgreSQL drivers using apt-get (Ubuntu/Debian)
# We also use docker-php-ext-install, which is the standard way to add PHP extensions in this image
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Maintain directory permissions for Render
# Note: Ubuntu-based images often use 'www-data' instead of 'apache', 
# but we will use 'www-data' here to ensure compatibility with the new base.
RUN mkdir -p /var/www/files /var/www/logs /etc/ssl/apache2 && \
    chown -R www-data:www-data /var/www/files /var/www/logs /etc/ssl/apache2 && \
    chmod -R 777 /var/www/files /var/www/logs /etc/ssl/apache2

# 4. Set environment variable for Render's HTTPS
ENV HTTPS=on

# 5. Expose port 80
EXPOSE 80
