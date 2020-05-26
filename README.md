# wp248-maintain-system
Collection of scripts to support during the setup of WordPress sites, but mostly for system maintenance.

./nginx
./nginx/setup - Used only during the setup time.

# Usefull commands

DISABLE_WP_CRON
wp config set DISABLE_WP_CRON true

Remmber:
after changing php.ini need to restart both services
sudo /opt/bitnami/ctlscript.sh restart php-fpm nginx
