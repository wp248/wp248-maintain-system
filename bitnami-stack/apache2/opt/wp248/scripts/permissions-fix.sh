#!/usr/bin/env bash

sudo chown -R bitnami:daemon /opt/bitnami/apps/wordpress/htdocs
sudo find /opt/bitnami/apps/wordpress/htdocs -type d -exec chmod 775 {} \;
sudo find /opt/bitnami/apps/wordpress/htdocs -type f -exec chmod 664 {} \;
sudo chmod 640 /opt/bitnami/apps/wordpress/htdocs/wp-config.php
