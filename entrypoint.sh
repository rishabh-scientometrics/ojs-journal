#!/bin/bash

DB_HOST="dpg-d6iahrjuibrs73ekgr2g-a.singapore-postgres.render.com"
DB_USER="ojs_database_user"
DB_PASS="LcwV3769J87Ef1Jfx6I9uV4p3sS4B6fd"
DB_NAME="ojs_database"

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

echo '=== Config check ==='
grep -E "^\s*(driver|host|username|password|name|installed)\s*=" /var/www/html/config.inc.php | grep -v '^;'

echo '=== PKPRouter patches ==='
sed -n '198,210p' /var/www/html/lib/pkp/classes/core/PKPRouter.php

TABLES=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c \
  "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' \n')
echo "=== Tables in DB: $TABLES ==="

if [ "$TABLES" = "0" ] || [ -z "$TABLES" ]; then
    echo "=== Starting Apache for web install ==="
    apache2ctl start
    sleep 10

    echo "=== POSTing to web installer ==="
    curl -v -X POST "http://localhost/index.php/install/install" \
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
      --data-urlencode "install=1" 2>&1 | tail -50

    echo "=== Apache error log ==="
    tail -20 /var/log/apache2/error.log

    TABLES_AFTER=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c \
      "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' \n')
    echo "=== Tables after install: $TABLES_AFTER ==="
fi

exec apache2ctl -DFOREGROUND
