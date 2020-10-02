#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e

sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt install memcached locate telnet git rsync -y
# Image procssing uils
sudo apt install libjpeg-progs  jpegoptim gifsicle optipng pngquant webp -y


rsync -av -P ubuntu@royalage.com:/var/www/sftp/  /opt/bitnami/apps/wordpress/sftp/
sudo mkdir -p /opt/bitnami/apps/wordpress/sftp/
sudo chown -Rf bitnami:daemon /opt/bitnami/apps/wordpress/sftp/
rsync -av -P ubuntu@royalage.com:/var/www/sftp/  /opt/bitnami/apps/wordpress/sftp/



sudo mkdir -p /opt/bitnami/apps/wordpress/prod.bak
sudo chown -Rf bitnami:daemon  /opt/bitnami/apps/wordpress/prod.bak
rsync -av -P ubuntu@royalage.com:/var/www/royalage.com/ /opt/bitnami/apps/wordpress/prod.bak/
