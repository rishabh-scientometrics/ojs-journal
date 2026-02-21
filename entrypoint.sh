#!/bin/bash

sed -i "s/host = localhost/host = dpg-d6d0m8ktgctc73es4c80-a/" /var/www/html/config.inc.php
sed -i "s/username = ojs/username = ojsuser/" /var/www/html/config.inc.php
sed -i "s/password = ojs/password = FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW/" /var/www/html/config.inc.php
sed -i "/^\[database\]/,/^\[/ s/^name =.*/name = ojs_db/" /var/www/html/config.inc.php
sed -i "s/installed = On/installed = Off/" /var/www/html/config.inc.php

# Fix permissions before running installer
chmod -R 777 /var/www/html/cache /var/www/html/public /var/www/files

# Run CLI installer as www-data
cd /var/www/html
su -s /bin/bash www-data -c "php tools/install.php \
  --adminUsername=rishabhs03 \
  --adminPassword=Punjab-101 \
  --adminEmail=rishabh.scientometrics@gmail.com \
  --locale=en \
  --country=IN \
  --dbDriver=postgres \
  --dbHost=dpg-d6d0m8ktgctc73es4c80-a \
  --dbPort=5432 \
  --dbName=ojs_db \
  --dbUser=ojsuser \
  --dbPassword=FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW \
  --filesDir=/var/www/files \
  --noInteractive"

echo "=== Installer exit code: $? ==="

exec apache2-foreground
