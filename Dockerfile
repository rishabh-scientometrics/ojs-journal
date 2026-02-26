FROM pkpofficial/ojs:3_5_0-3
USER root

RUN apt-get update && apt-get install -y \
    default-mysql-client curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN if [ -f /var/www/html/config.TEMPLATE.inc.php ]; then \
    cp /var/www/html/config.TEMPLATE.inc.php /var/www/html/config.inc.php; \
    fi

RUN mkdir -p /var/www/files /var/www/logs && \
    chown -R www-data:www-data /var/www/html /var/www/files /var/www/logs && \
    chmod -R 777 /var/www/files /var/www/logs /var/www/html/cache /var/www/html/public

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
