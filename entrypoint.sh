#!/bin/bash
sed -i "s/host = localhost/host = $OJS_DB_HOST/" /var/www/html/config.inc.php
sed -i "s/port = 3306/port = ${OJS_DB_PORT:-5432}/" /var/www/html/config.inc.php
sed -i "s/username = ojs/username = $OJS_DB_USER/" /var/www/html/config.inc.php
sed -i "s/password = ojs/password = $OJS_DB_PASSWORD/" /var/www/html/config.inc.php
sed -i "s/name = ojs/name = $OJS_DB_NAME/" /var/www/html/config.inc.php

exec /bin/bash /opt/ojs/bin/ojs-start
