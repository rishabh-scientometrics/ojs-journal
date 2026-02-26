#!/bin/bash

DB_HOST="mysql-production-d880.up.railway.app"
DB_PORT="33060"
DB_USER="root"
DB_PASS="PHOouGKIDfOPVPZYkLfMZcggsjUxttsa"
DB_NAME="railway"

chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files
mkdir -p /var/www/html/cache/opcache
chmod -R 777 /var/www/html/cache/opcache
chown -R www-data:www-data /var/www/html/cache

# Write config
php -r "
\$config = file_get_contents('/var/www/html/config.inc.php');
\$config = preg_replace('/^(driver\s*=\s*).*$/m', '\${1}mysqli', \$config);
\$config = preg_replace('/^(host\s*=\s*).*$/m', '\${1}${DB_HOST}', \$config);
\$config = preg_replace('/^(port\s*=\s*).*$/m', '\${1}${DB_PORT}', \$config);
\$config = preg_replace('/^(username\s*=\s*).*$/m', '\${1}${DB_USER}', \$config);
\$config = preg_replace('/^(password\s*=\s*).*$/m', '\${1}${DB_PASS}', \$config);
\$config = preg_replace('/^(name\s*=\s*).*$/m', '\${1}${DB_NAME}', \$config);
\$config = preg_replace('/^(installed\s*=\s*).*$/m', '\${1}Off', \$config);
file_put_contents('/var/www/html/config.inc.php', \$config);
echo 'Config written' . PHP_EOL;
"

echo "=== Config check ==="
grep -E "^\s*(driver|host|port|username|password|name|installed)\s*=" /var/www/html/config.inc.php | grep -v "^;"

TABLES=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_NAME}';" 2>/dev/null)
echo "=== Tables in DB: $TABLES ==="

if [ "$TABLES" = "0" ] || [ -z "$TABLES" ]; then
    echo "=== Starting Apache for web install ==="
    apache2ctl start
    sleep 8

    echo "=== POSTing to web installer ==="
    RESULT=$(curl -s -X POST "http://localhost/index.php/install/install" \
      --data-urlencode "locale=en" \
      --data-urlencode "filesDir=/var/www/files" \
      --data-urlencode "adminUsername=admin" \
      --data-urlencode "adminPassword=Admin1234!" \
      --data-urlencode "adminPassword2=Admin1234!" \
      --data-urlencode "adminEmail=admin@example.com" \
      --data-urlencode "databaseDriver=mysqli" \
      --data-urlencode "databaseHost=${DB_HOST}" \
      --data-urlencode "databasePort=${DB_PORT}" \
      --data-urlencode "databaseUsername=${DB_USER}" \
      --data-urlencode "databasePassword=${DB_PASS}" \
      --data-urlencode "databaseName=${DB_NAME}" \
      --data-urlencode "install=1" 2>&1)

    echo "$RESULT" | tail -20

    TABLES_AFTER=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_NAME}';" 2>/dev/null)
    echo "=== Tables after install: $TABLES_AFTER ==="
fi

exec apache2ctl -DFOREGROUND
