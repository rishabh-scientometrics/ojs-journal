#!/bin/bash

DB_HOST="dpg-d6d0m8ktgctc73es4c80-a"
DB_USER="ojsuser"
DB_PASS="FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW"
DB_NAME="ojs_db"

chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files
mkdir -p /var/www/html/cache/opcache
chmod -R 777 /var/www/html/cache/opcache
chown -R www-data:www-data /var/www/html/cache

php -r "
\$config = file_get_contents('/var/www/html/config.inc.php');
\$config = preg_replace('/^(driver\s*=\s*).*$/m', '\${1}postgres', \$config);
\$config = preg_replace('/^(host\s*=\s*).*$/m', '\${1}${DB_HOST}', \$config);
\$config = preg_replace('/^(username\s*=\s*).*$/m', '\${1}${DB_USER}', \$config);
\$config = preg_replace('/^(password\s*=\s*).*$/m', '\${1}${DB_PASS}', \$config);
\$config = preg_replace('/^(name\s*=\s*).*$/m', '\${1}${DB_NAME}', \$config);
\$config = preg_replace('/^(installed\s*=\s*).*$/m', '\${1}Off', \$config);
file_put_contents('/var/www/html/config.inc.php', \$config);
echo 'Config written' . PHP_EOL;
"

TABLES=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c \
  "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' \n')
echo "=== Tables in DB: $TABLES ==="

if [ "$TABLES" = "0" ] || [ -z "$TABLES" ]; then
    echo "=== Starting Apache for web install ==="
    apache2ctl start
    sleep 10

    echo "=== POSTing to web installer ==="
    curl -s -X POST "http://localhost/index.php/install/install" \
      --data-urlencode "locale=en" \
      --data-urlencode "filesDir=/var/www/files" \
      --data-urlencode "adminUsername=admin" \
      --data-urlencode "adminPassword=Admin1234!" \
      --data-urlencode "adminPassword2=Admin1234!" \
      --data-urlencode "adminEmail=admin@example.com" \
      --data-urlencode "databaseDriver=postgres9" \
      --data-urlencode "databaseHost=${DB_HOST}" \
      --data-urlencode "databaseUsername=${DB_USER}" \
      --data-urlencode "databasePassword=${DB_PASS}" \
      --data-urlencode "databaseName=${DB_NAME}" \
      --data-urlencode "install=1" 2>&1 | tail -20

    TABLES_AFTER=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c \
      "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' \n')
    echo "=== Tables after install: $TABLES_AFTER ==="
fi

exec apache2ctl -DFOREGROUND
