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
    
# Patch PKPPageRouter - wrap getByPath in try/catch
RUN sed -i 's/Application::getContextDAO()->getByPath(\$contextPath)/@Application::getContextDAO()->getByPath(\$contextPath)/g' \
    /var/www/html/lib/pkp/classes/core/PKPPageRouter.php

RUN sed -i "s/public static function isInstalled.*$/public static function isInstalled(): bool { return false; }/" \
    /var/www/html/lib/pkp/classes/core/PKPApplication.php 2>/dev/null || true
    
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN mkdir -p /var/www/files /var/www/logs && \
    chown -R www-data:www-data /var/www/html /var/www/files /var/www/logs && \
    chmod -R 777 /var/www/files /var/www/logs /var/www/html/cache /var/www/html/public

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
