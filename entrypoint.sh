#!/bin/bash

sed -i "s/host = localhost/host = dpg-d6d0m8ktgctc73es4c80-a/" /var/www/html/config.inc.php
sed -i "s/username = ojs/username = ojsuser/" /var/www/html/config.inc.php
sed -i "s/password = ojs/password = YOUR_PASSWORD/" /var/www/html/config.inc.php
sed -i "/^\[database\]/,/^\[/ s/^name =.*/name = ojs_db/" /var/www/html/config.inc.php
sed -i "s/installed = On/installed = Off/" /var/www/html/config.inc.php

chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files

cd /var/www/html
printf 'en\n\n/var/www/files\nadmin\nAdmin1234!\nAdmin1234!\nadmin@example.com\npostgres\ndpg-d6d0m8ktgctc73es4c80-a\n5432\nojs_db\nojsuser\nYOUR_PASSWORD\n' | su -s /bin/bash www-data -c "php -d auto_prepend_file='' tools/install.php"

echo "=== Installer exit code: $? ==="

exec apache2-foreground
