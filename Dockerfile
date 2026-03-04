FROM pkpofficial/ojs:3_5_0-3
USER root

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

COPY patch.php /tmp/patch.php
RUN find /etc/php -name "php.ini" | xargs -I{} sh -c 'echo "error_log = /dev/stdout" >> {} && echo "display_errors = On" >> {} && echo "log_errors = On" >> {}'

RUN echo "error_log = /dev/stdout" >> /etc/php/8.3/apache2/php.ini && \
    echo "display_errors = On" >> /etc/php/8.3/apache2/php.ini && \
    echo "log_errors = On" >> /etc/php/8.3/apache2/php.ini

RUN sed -i 's|ErrorLog .*|ErrorLog /dev/stdout|g' /etc/apache2/apache2.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN mkdir -p /var/www/files /var/www/logs && \
    chown -R www-data:www-data /var/www/html /var/www/files /var/www/logs && \
    chmod -R 777 /var/www/files /var/www/logs /var/www/html/cache /var/www/html/public

RUN printf '#!/bin/bash\n\
DB_HOST="dpg-d6iahrjuibrs73ekgr2g-a.singapore-postgres.render.com"\n\
DB_USER="ojs_database_user"\n\
DB_PASS="LcwV3769J87Ef1Jfx6I9uV4p3sS4B6fd"\n\
DB_NAME="ojs_database"\n\
chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files\n\
mkdir -p /var/www/html/cache/opcache\n\
chmod -R 777 /var/www/html/cache/opcache\n\
chown -R www-data:www-data /var/www/html/cache\n\
php -r "\$config = file_get_contents('"'"'/var/www/html/config.inc.php'"'"'); \$config = preg_replace('"'"'/^(driver\s*=\s*).*$/m'"'"', '"'"'\${1}postgres'"'"', \$config); \$config = preg_replace('"'"'/^(host\s*=\s*).*$/m'"'"', '"'"'\${1}'"'"'\"$DB_HOST\"'"'"''"'"', \$config); \$config = preg_replace('"'"'/^(username\s*=\s*).*$/m'"'"', '"'"'\${1}'"'"'\"$DB_USER\"'"'"''"'"', \$config); \$config = preg_replace('"'"'/^(password\s*=\s*).*$/m'"'"', '"'"'\${1}'"'"'\"$DB_PASS\"'"'"''"'"', \$config); \$config = preg_replace('"'"'/^(name\s*=\s*).*$/m'"'"', '"'"'\${1}'"'"'\"$DB_NAME\"'"'"''"'"', \$config); \$config = preg_replace('"'"'/^(installed\s*=\s*).*$/m'"'"', '"'"'\${1}Off'"'"', \$config); file_put_contents('"'"'/var/www/html/config.inc.php'"'"', \$config); echo '"'"'Config written'"'"' . PHP_EOL;"\n\
TABLES=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='"'"'public'"'"';" 2>/dev/null | tr -d '"'"' \n'"'"')\n\
echo "=== Tables in DB: $TABLES ==="\n\
exec apache2ctl -DFOREGROUND\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 80
