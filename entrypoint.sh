#!/bin/bash

chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files
mkdir -p /var/www/html/cache/opcache
chmod -R 777 /var/www/html/cache/opcache
chown -R www-data:www-data /var/www/html/cache

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

TABLES=$(PGPASSWORD=FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW psql -h dpg-d6d0m8ktgctc73es4c80-a -U ojsuser -d ojs_db -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' ')
echo "=== Tables in DB: $TABLES ==="

if [ "$TABLES" = "0" ] || [ -z "$TABLES" ]; then
    echo "=== Installing via upgrade tool ==="
    cd /var/www/html
    su -s /bin/bash www-data -c "php tools/upgrade.php install" 2>&1
    echo "=== Upgrade exit code: $? ==="

    TABLES_AFTER=$(PGPASSWORD=FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW psql -h dpg-d6d0m8ktgctc73es4c80-a -U ojsuser -d ojs_db -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' ')
    echo "=== Tables after install: $TABLES_AFTER ==="
fi

exec apache2-foreground
fi

exec apache2-foreground
