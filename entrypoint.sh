#!/bin/bash

chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files

# Directly write correct DB config using PHP
php -r "
\$config = file_get_contents('/var/www/html/config.inc.php');
\$config = preg_replace('/driver = .*/', 'driver = postgres', \$config);
\$config = preg_replace('/host = .*/', 'host = dpg-d6d0m8ktgctc73es4c80-a', \$config);
\$config = preg_replace('/port = .*/', 'port = 5432', \$config);
\$config = preg_replace('/username = .*/', 'username = ojsuser', \$config);
\$config = preg_replace('/password = .*/', 'password = FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW', \$config);
\$config = preg_replace('/name = .*/', 'name = ojs_db', \$config);
\$config = preg_replace('/installed = On/', 'installed = Off', \$config);
file_put_contents('/var/www/html/config.inc.php', \$config);
"

grep -A10 "\[database\]" /var/www/html/config.inc.php

cd /var/www/html
printf 'en\n\n/var/www/files\nadmin\nAdmin1234!\nAdmin1234!\nadmin@example.com\npostgres\ndpg-d6d0m8ktgctc73es4c80-a\n5432\nojs_db\nojsuser\nFpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW\n' | su -s /bin/bash www-data -c "php -d auto_prepend_file='' tools/install.php"

echo "=== Installer exit code: $? ==="

exec apache2-foreground
