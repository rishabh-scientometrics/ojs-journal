#!/bin/bash

chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files

# Fix config using PHP with more precise patterns
php -r "
\$config = file_get_contents('/var/www/html/config.inc.php');
\$config = preg_replace('/^driver = .*/m', 'driver = postgres', \$config);
\$config = preg_replace('/^host = .*/m', 'host = dpg-d6d0m8ktgctc73es4c80-a', \$config);
\$config = preg_replace('/^port = .*/m', 'port = 5432', \$config);
\$config = preg_replace('/^username = .*/m', 'username = ojsuser', \$config);
\$config = preg_replace('/^password = .*/m', 'password = FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW', \$config);
\$config = preg_replace('/^name = .*/m', 'name = ojs_db', \$config);
\$config = preg_replace('/^installed = On/m', 'installed = Off', \$config);
file_put_contents('/var/www/html/config.inc.php', \$config);
"

grep -A10 "\[database\]" /var/www/html/config.inc.php

cd /var/www/html
printf 'en\n\n/var/www/files\nadmin\nAdmin1234!\nAdmin1234!\nadmin@example.com\npostgres9\ndpg-d6d0m8ktgctc73es4c80-a\n5432\nojs_db\nojsuser\nFpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW\n' | su -s /bin/bash www-data -c "php -d auto_prepend_file='' tools/install.php"

echo "=== Installer exit code: $? ==="

exec apache2-foreground
