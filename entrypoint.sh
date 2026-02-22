#!/bin/bash

chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files
mkdir -p /var/www/html/cache/opcache
chmod -R 777 /var/www/html/cache/opcache
chown -R www-data:www-data /var/www/html/cache

# Write config
php -r "
\$config = file_get_contents('/var/www/html/config.inc.php');
\$config = preg_replace('/^driver = .*/m', 'driver = postgres', \$config);
\$config = preg_replace('/^host = .*/m', 'host = dpg-d6d0m8ktgctc73es4c80-a', \$config);
\$config = preg_replace('/^username = .*/m', 'username = ojsuser', \$config);
\$config = preg_replace('/^password = .*/m', 'password = FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW', \$config);
\$config = preg_replace('/^name = .*/m', 'name = ojs_db', \$config);
\$config = str_replace('installed = On', 'installed = Off', \$config);
file_put_contents('/var/www/html/config.inc.php', \$config);
echo 'Config written\n';
"

TABLES=$(PGPASSWORD=FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW psql -h dpg-d6d0m8ktgctc73es4c80-a -U ojsuser -d ojs_db -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' ')
echo "=== Tables in DB: $TABLES ==="

if [ "$TABLES" = "0" ] || [ -z "$TABLES" ]; then
    echo "=== Starting Apache for web install ==="
    apache2ctl start
    sleep 5

    echo "=== POSTing to web installer ==="
    curl -v -X POST "http://localhost/index.php/install/install" \
      --data-urlencode "locale=en" \
      --data-urlencode "filesDir=/var/www/files" \
      --data-urlencode "adminUsername=admin" \
      --data-urlencode "adminPassword=Admin1234!" \
      --data-urlencode "adminPassword2=Admin1234!" \
      --data-urlencode "adminEmail=admin@example.com" \
      --data-urlencode "databaseDriver=postgres9" \
      --data-urlencode "databaseHost=dpg-d6d0m8ktgctc73es4c80-a" \
      --data-urlencode "databaseUsername=ojsuser" \
      --data-urlencode "databasePassword=FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW" \
      --data-urlencode "databaseName=ojs_db" \
      --data-urlencode "install=1" 2>&1 | tail -50

    TABLES_AFTER=$(PGPASSWORD=FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW psql -h dpg-d6d0m8ktgctc73es4c80-a -U ojsuser -d ojs_db -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' ')
    echo "=== Tables after install: $TABLES_AFTER ==="

    # Apache already running, just exec to foreground process
    exec apache2ctl -DFOREGROUND
fi

exec apache2-foreground
