#!/usr/bin/env bash

# Date stamp to used in all renames, backup, log files
DATESTAMP=$(date +"%Y%m%d-%H%M%S")
DOMAIN=wp248.com

# Create Backup for current config
sudo cp /opt/bitnami/nginx/conf/nginx-app.conf /opt/bitnami/nginx/conf/nginx-app.conf.${DATESTAMP}
echo "include \"/opt/bitnami/apps/wordpress/conf/wp248-cors.conf\";" >> /opt/bitnami/nginx/conf/nginx-app.conf

sudo cp /opt/bitnami/nginx/conf/nginx.conf /opt/bitnami/nginx/conf/nginx.conf.${DATESTAMP}
sed -i '/include \"/opt/bitnami/apps/wordpress/conf/wp248-cors.conf\";/i line1 line2' zzz.txt

# Do remove the enter at the end , needed for CRLF
sudo sed -i '\/include \"\/opt\/bitnami\/nginx\/conf\/bitnami\/bitnami.conf\"/i \
include "\/opt\/bitnami\/nginx\/conf\/wp248-bitnami-nginx.conf\"; \
'  /opt/bitnami/nginx/conf/nginx.conf


sudo mv /opt/bitnami/nginx/conf/mime.types /opt/bitnami/nginx/conf/mime.types.${DATESTAMP}
sudo cp /opt/bitnami/nginx/conf/mime.types.mod /opt/bitnami/nginx/conf/mime.types


sudo mv /opt/bitnami/nginx/conf/bitnami/bitnami.conf /opt/bitnami/nginx/conf/bitnami/bitnami.conf.${DATESTAMP}


sudo sed 's/example.com/${DOMAIN}/g' /opt/bitnami/nginx/conf/bitnami/bitnami.conf.mod  > /opt/bitnami/nginx/conf/bitnami/bitnami.conf
