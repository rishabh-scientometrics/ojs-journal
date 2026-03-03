#!/bin/bash

DB_HOST="dpg-d6iahrjuibrs73ekgr2g-a.singapore-postgres.render.com"
DB_USER="ojs_database_user"
DB_PASS="LcwV3769J87Ef1Jfx6I9uV4p3sS4B6fd"
DB_NAME="ojs_database"

chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files
mkdir -p /var/www/html/cache/opcache
chmod -R 777 /var/www/html/cache/opcache
chown -R www-data:www-data /var/www/html/cache

php -r "\$config = file_get_contents('/var/www/html/config.inc.php'); \$config = preg_replace('/^(driver\s*=\s*).*$/m', '\${1}postgres', \$config); \$config = preg_replace('/^(host\s*=\s*).*$/m', '\${1}${DB_HOST}', \$config); \$config = preg_replace('/^(username\s*=\s*).*$/m', '\${1}${DB_USER}', \$config); \$config = preg_replace('/^(password\s*=\s*).*$/m', '\${1}${DB_PASS}', \$config); \$config = preg_replace('/^(name\s*=\s*).*$/m', '\${1}${DB_NAME}', \$config); \$config = preg_replace('/^(installed\s*=\s*).*$/m', '\${1}Off', \$config); file_put_contents('/var/www/html/config.inc.php', \$config); echo 'Config written' . PHP_EOL;"

TABLES=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' \n')
echo "=== Tables in DB: $TABLES ==="

# Redirect Apache logs to stdout
ln -sf /proc/1/fd/1 /var/log/apache2/access.log
ln -sf /proc/1/fd/1 /var/log/apache2/error.log

exec apache2ctl -DFOREGROUND
