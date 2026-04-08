FROM pkpofficial/ojs:3_5_0-3
USER root
RUN echo "cache-bust-19" > /dev/null
RUN apt-get update && apt-get install -y \
    postgresql-client curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN a2dismod ssl 2>/dev/null || true && \
    a2dissite default-ssl 2>/dev/null || true && \
    rm -f /etc/apache2/conf-enabled/pkp.conf && \
    rm -f /etc/apache2/sites-enabled/*ssl* 2>/dev/null || true
RUN sed -i 's/\$this->_context = \$contextDao->getByPath(\$path);/try { \$this->_context = \$contextDao->getByPath(\$path); } catch (\\Exception \$e) { \$this->_context = null; }/' \
    /var/www/html/lib/pkp/classes/core/PKPRouter.php
RUN sed -i 's/throw new \\Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException();//' \
    /var/www/html/lib/pkp/classes/core/PKPRouter.php
RUN sed -i 's/Application::getContextDAO()->getByPath(\$contextPath)/@Application::getContextDAO()->getByPath(\$contextPath)/g' \
    /var/www/html/lib/pkp/classes/core/PKPPageRouter.php
RUN rm -rf /var/www/html/plugins/importexport/doaj
COPY patch.php /tmp/patch.php
RUN php /tmp/patch.php
RUN find /etc/php -name "php.ini" | xargs -I{} sh -c 'echo "error_log = /dev/stdout" >> "{}" && echo "display_errors = On" >> "{}" && echo "log_errors = On" >> "{}"'
RUN sed -i 's|ErrorLog .*|ErrorLog /dev/stdout|g' /etc/apache2/apache2.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN echo "SetEnvIf X-Forwarded-Proto https HTTPS=on" >> /etc/apache2/apache2.conf
RUN sed -i 's/^installed[ ]*=[ ]*.*/installed = On/' /var/www/html/config.inc.php && \
    sed -i 's/^driver[ ]*=[ ]*.*/driver = postgres/' /var/www/html/config.inc.php && \
    sed -i 's/^host[ ]*=[ ]*.*/host = aws-1-ap-southeast-1.pooler.supabase.com/' /var/www/html/config.inc.php && \
    sed -i 's/^username[ ]*=[ ]*.*/username = postgres.zoqalnmafvyuhzwroydk/' /var/www/html/config.inc.php && \
    sed -i 's/^password[ ]*=[ ]*.*/password = 4R8eKxRCBi0pybyq/' /var/www/html/config.inc.php && \
    sed -i 's/^name[ ]*=[ ]*.*/name = postgres/' /var/www/html/config.inc.php && \
    sed -i 's|^base_url[ ]*=[ ]*.*|base_url = https://ojs-journal-2.onrender.com|' /var/www/html/config.inc.php
RUN sed -i 's|^app_key.*|app_key = base64:TLxsRoEr0l8sS2IFaynE6ObjaqIWLAHSG2xZxiY7qqw=|' /var/www/html/config.inc.php
RUN mkdir -p /var/www/files /var/www/logs /usageStats/usageEventLogs && \
    chown -R www-data:www-data /var/www/html /var/www/files /var/www/logs /usageStats && \
    chmod -R 777 /var/www/files /var/www/logs /var/www/html/cache /var/www/html/public /usageStats
RUN printf '#!/bin/bash\n\
chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files /usageStats\n\
mkdir -p /var/www/html/cache/opcache\n\
chmod -R 777 /var/www/html/cache/opcache\n\
chown -R www-data:www-data /var/www/html/cache\n\
rm -rf /var/www/html/cache/*\n\
exec apache2ctl -DFOREGROUND\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 80
