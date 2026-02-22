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

# Check if already installed
TABLES=\$(PGPASSWORD=FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW psql -h dpg-d6d0m8ktgctc73es4c80-a -U ojsuser -d ojs_db -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' ')

echo "=== Tables in DB: $TABLES ==="

if [ "$TABLES" = "0" ] || [ -z "$TABLES" ]; then
    echo "=== Running OJS installer ==="
    cd /var/www/html
    php -r "
    define('INDEX_FILE_LOCATION', '/var/www/html/index.php');
    \$_SERVER['HTTP_HOST'] = 'ojs-journal-1.onrender.com';
    \$_SERVER['REQUEST_URI'] = '/index.php/install/install';
    \$_SERVER['REQUEST_METHOD'] = 'POST';
    \$_POST = [
        'locale' => 'en',
        'additionalLocales' => [],
        'filesDir' => '/var/www/files',
        'adminUsername' => 'admin',
        'adminPassword' => 'Admin1234!',
        'adminPassword2' => 'Admin1234!',
        'adminEmail' => 'admin@example.com',
        'databaseDriver' => 'postgres9',
        'databaseHost' => 'dpg-d6d0m8ktgctc73es4c80-a',
        'databaseUsername' => 'ojsuser',
        'databasePassword' => 'FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW',
        'databaseName' => 'ojs_db',
        'install' => '1',
    ];
    require('/var/www/html/index.php');
    " 2>&1
    echo "=== Install done ==="
fi

exec apache2-foreground
