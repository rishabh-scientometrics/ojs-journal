FROM pkpofficial/ojs:3_5_0-3
USER root

RUN apt-get update && apt-get install -y \
    postgresql-client curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Disable SSL completely
RUN a2dismod ssl 2>/dev/null || true && \
    a2dissite default-ssl 2>/dev/null || true && \
    rm -f /etc/apache2/conf-enabled/pkp.conf && \
    rm -f /etc/apache2/sites-enabled/*ssl* && \
    rm -f /etc/apache2/sites-enabled/*443*

# Patch PKPRouter to catch DB errors during install
RUN sed -i 's/\$context = \$contextDAO->getByPath(\$contextPath);/try { \$context = \$contextDAO->getByPath(\$contextPath); } catch (\\Exception \$e) { \$context = null; }/' \
    /var/www/html/lib/pkp/classes/core/PKPRouter.php

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN mkdir -p /var/www/files /var/www/logs && \
    chown -R www-data:www-data /var/www/html /var/www/files /var/www/logs && \
    chmod -R 777 /var/www/files /var/www/logs /var/www/html/cache /var/www/html/public

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
