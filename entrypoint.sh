#!/bin/bash

sed -i "s/host = localhost/host = dpg-d6d0m8ktgctc73es4c80-a/" /var/www/html/config.inc.php
sed -i "s/username = ojs/username = ojsuser/" /var/www/html/config.inc.php
sed -i "s/password = ojs/password = FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW/" /var/www/html/config.inc.php
sed -i "/^\[database\]/,/^\[/ s/^name =.*/name = ojs_db/" /var/www/html/config.inc.php
sed -i "s/installed = On/installed = Off/" /var/www/html/config.inc.php

# Fix permissions before running installer
chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files

# Run CLI installer as www-data
# Run CLI installer as www-data
cd /var/www/html
echo "en
IN
rishabhs03
Punjab101
rishabh.scientometrics@gmail.com
postgres
dpg-d6d0m8ktgctc73es4c80-a
5432
ojs_db
ojsuser
FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW
/var/www/files
" | su -s /bin/bash www-data -c "php tools/install.php"

echo "=== Installer exit code: $? ==="

exec apache2-foreground
