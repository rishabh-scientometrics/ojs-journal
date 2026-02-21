#!/bin/bash

sed -i "s/host = localhost/host = dpg-d6d0m8ktgctc73es4c80-a/" /var/www/html/config.inc.php
sed -i "s/username = ojs/username = ojsuser/" /var/www/html/config.inc.php
sed -i "s/password = ojs/password = FpgX7WWDWxhqRXnEg6E4QTVIxM1fBsuW/" /var/www/html/config.inc.php
sed -i "/^\[database\]/,/^\[/ s/^name =.*/name = ojs_db/" /var/www/html/config.inc.php
sed -i "s/installed = On/installed = Off/" /var/www/html/config.inc.php

grep -A8 "\[database\]" /var/www/html/config.inc.php

exec apache2-foreground
