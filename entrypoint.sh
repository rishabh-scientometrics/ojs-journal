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

# Run installer using PHP's built-in input handling
cd /var/www/html
php tools/install.php \
  --locale=en \
  --additionalLocales= \
  --filesDir=/var/www/files \
  --adminUsername=admin \
  --adminPassword=Admin1234! \
  --adminEmail=admin@example.com \
  --dbDriver=postgres9 \
  --dbHost=dpg-d6d0m8ktgctc73es4c80-a \
  --dbUsername=ojsuser \
  --dbPassword=FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW \
  --dbName=ojs_db \
  --noInteractive 2>&1

echo "=== Installer exit code: $? ==="

php -r "
try {
    \$pdo = new PDO('pgsql:host=dpg-d6d0m8ktgctc73es4c80-a;dbname=ojs_db', 'ojsuser', 'FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW');
    \$result = \$pdo->query(\"SELECT count(*) FROM information_schema.tables WHERE table_schema='public'\");
    echo 'Tables in DB: ' . \$result->fetchColumn() . PHP_EOL;
} catch(Exception \$e) {
    echo 'DB check error: ' . \$e->getMessage() . PHP_EOL;
}
"

exec apache2-foreground
