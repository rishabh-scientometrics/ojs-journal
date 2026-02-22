#!/bin/bash

chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files

php -r "
\$config = file_get_contents('/var/www/html/config.inc.php');
\$config = preg_replace('/(\[database\].*?\ndriver = )[\w]+/s', '\${1}postgres', \$config);
\$config = preg_replace('/(\[database\].*?\nhost = )[\w\.\-]+/s', '\${1}dpg-d6d0m8ktgctc73es4c80-a', \$config);
\$config = preg_replace('/(\[database\].*?\nusername = )[\w]+/s', '\${1}ojsuser', \$config);
\$config = preg_replace('/(\[database\].*?\npassword = )[\w]+/s', '\${1}FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW', \$config);
\$config = preg_replace('/(\[database\].*?\nname = )[\w]+/s', '\${1}ojs_db', \$config);
\$config = str_replace('installed = On', 'installed = Off', \$config);
file_put_contents('/var/www/html/config.inc.php', \$config);
"

# Find and run the postgres schema SQL directly
echo "=== Looking for schema files ==="
find /var/www/html -name "*.sql" | grep -i postgres | head -20

exec apache2-foreground
