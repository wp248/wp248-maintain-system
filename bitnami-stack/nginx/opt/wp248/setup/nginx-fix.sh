#!/usr/bin/env bash

# Date stamp to used in all renames, backup, log files
DATESTAMP=$(date +"%Y%m%d-%H%M%S")
DOMAIN=wp248.com

printf "=========[ START nginx CONFIG ${DATESTAMP} ]=========\r\n"
printf "Step 1: Fixing /opt/bitnami/apps/wordpress/conf/nginx-app.conf \r\n"

# Create Backup for current config
printf "Step 1.1: make backup  \r\n"
sudo cp /opt/bitnami/apps/wordpress/conf/nginx-app.conf /opt/bitnami/apps/wordpress/conf/nginx-app.conf.${DATESTAMP}
printf "Step 1.2: modify config  \r\n"
echo "include \"/opt/bitnami/apps/wordpress/conf/wp248-cors.conf\";" >> /opt/bitnami/apps/wordpress/conf/nginx-app.conf



printf "Step 2: Fixing /opt/bitnami/nginx/conf/nginx.conf  \r\n"
printf "Step 2.1: make backup  \r\n"
sudo cp /opt/bitnami/nginx/conf/nginx.conf /opt/bitnami/nginx/conf/nginx.conf.${DATESTAMP}
printf "Step 2.2: modify config  \r\n"
# Do remove the enter at the end , needed for CRLF
sudo sed -i '\/include \"\/opt\/bitnami\/nginx\/conf\/bitnami\/bitnami.conf\"/i \
include "\/opt\/bitnami\/nginx\/conf\/wp248-bitnami-nginx.conf\"; \
'  /opt/bitnami/nginx/conf/nginx.conf

printf "Step 3: Fixing /opt/bitnami/nginx/conf/mime.types  \r\n"
printf "Step 3.1: make backup  \r\n"
sudo mv /opt/bitnami/nginx/conf/mime.types /opt/bitnami/nginx/conf/mime.types.${DATESTAMP}
printf "Step 3.2: modify config  \r\n"
sudo cp /opt/bitnami/nginx/conf/mime.types.mod /opt/bitnami/nginx/conf/mime.types


printf "Step 4: Fixing /opt/bitnami/nginx/conf/bitnami/bitnami.conf  \r\n"
printf "Step 4.1: make backup  \r\n"
sudo mv /opt/bitnami/nginx/conf/bitnami/bitnami.conf /opt/bitnami/nginx/conf/bitnami/bitnami.conf.${DATESTAMP}
printf "Step 4.2: modify config into tmp \r\n"

sudo sed 's/example.com/${DOMAIN}/g' /opt/bitnami/nginx/conf/bitnami/bitnami.conf.mod  > /opt/wp248/setup/tmp/bitnami.conf
printf "Step 4.3: replacing config  \r\n"
sudo mv /opt/wp248/setup/bitnami.conf /opt/bitnami/nginx/conf/bitnami/bitnami.conf

printf "Step 5: Test nginx config & restart services  \r\n"

sudo nginx -t && sudo /opt/bitnami/ctlscript.sh restart php-fpm nginx
printf "=========[ END nginx CONFIG ${DATESTAMP} ]=========\r\n"
