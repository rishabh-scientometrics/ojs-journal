#!/bin/bash
# Replace database config using exact OJS template defaults
sed -i "s/host = localhost/host = $OJS_DB_HOST/" /var/www/html/config.inc.php
sed -i "s/port = 5432/port = ${OJS_DB_PORT:-5432}/" /var/www/html/config.inc.php
sed -i "s/username = ojs/username = $OJS_DB_USER/" /var/www/html/config.inc.php
sed -i "s/password = ojs/password = $OJS_DB_PASSWORD/" /var/www/html/config.inc.php
sed -i "s/name = ojs/name = $OJS_DB_NAME/" /var/www/html/config.inc.php

# Force-set any remaining localhost/default values
sed -i "/^\[database\]/,/^\[/ s/^port =.*/port = ${OJS_DB_PORT:-5432}/" /var/www/html/config.inc.php
sed -i "/^\[database\]/,/^\[/ s/^name =.*/name = $OJS_DB_NAME/" /var/www/html/config.inc.php

grep -A8 "\[database\]" /var/www/html/config.inc.php

exec apache2-foreground
