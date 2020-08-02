#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e
sudo apt-get install libjpeg-progs  jpegoptim gifsicle optipng pngquant webp -y

sudo chmod +x /opt/bitnami/apps/wordpress/htdocs/wp-content/ewww/cwebp
sudo chmod +x /opt/bitnami/apps/wordpress/htdocs/wp-content/ewww/gifsicle
sudo chmod +x /opt/bitnami/apps/wordpress/htdocs/wp-content/ewww/jpegtran
sudo chmod +x /opt/bitnami/apps/wordpress/htdocs/wp-content/ewww/optipng
