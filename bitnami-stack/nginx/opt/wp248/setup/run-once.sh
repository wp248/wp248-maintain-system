#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Date stamp to used in all renames, backup, log files
DATESTAMP=$(date +"%Y%m%d-%H%M%S")

# Bitnami default wordpress doc root
SITE_DIR=/opt/bitnami/apps/wordpress/htdocs/

# Backup directory, we recommend it to be outside of HTTP root directory
SITE_BAK=/opt/bitnami/apps/wordpress/wp-update-backups/

CRT_EMAIL=webmaster@yoursite.com
CRT_PRIMARY_DOMAIN=yoursite.com
CRT_SECONDARY_DOMAIN=www.yoursite.com

function disable_banner() {
	# Disable Banner
	sudo /opt/bitnami/apps/wordpress/bnconfig --disable_banner 1
}

function setup_ssl() {
	local CRT_DIR=/opt/bitnami/nginx/conf
	local LET_DIR=/opt/bitnami/letsencrypt/certificates

	# Stop Service
	sudo /opt/bitnami/ctlscript.sh stop nginx

	sudo /opt/bitnami/letsencrypt/lego --http --tls --accept-tos --email="${CRT_EMAIL}"\
									   --domains="${CRT_PRIMARY_DOMAIN}" \
									   --domains="${CRT_SECONDARY_DOMAIN}" \
									   --path="/opt/bitnami/letsencrypt" run

	sudo mv ${CRT_DIR}/server.{crt,backup.${DATESTAMP}}
	sudo mv ${CRT_DIR}/server.{key,backup.${DATESTAMP}}
	sudo mv ${CRT_DIR}/server.{csr,backup.${DATESTAMP}}

	# sudo ls -lah /opt/bitnami/letsencrypt/certificates/

	sudo ln -sf ${LET_DIR}/${CRT_PRIMARY_DOMAIN}.key ${CRT_DIR}/server.key
	sudo ln -sf ${LET_DIR}/${CRT_PRIMARY_DOMAIN}.crt ${CRT_DIR}/server.crt

	# Modify Certificate owners and security
	sudo chown root:root ${CRT_DIR}/server*
	sudo chmod 600 ${CRT_DIR}/server*

	# Restart Service
	sudo /opt/bitnami/ctlscript.sh start nginx

	# ls -lah /opt/bitnami/nginx/conf/
}

function setup_modify_php() {
	local PHP_DIR=/opt/bitnami/php/etc

	# Create Backup
	sudo cp ${PHP_DIR}/php.{ini,backup.${DATESTAMP}}

	sudo cat ${PHP_DIR}/php.mod >>  ${PHP_DIR}/php.ini
}

function wp_install_plugins() {
	# Install new site plugins and activate
	local wp_plugins=("elementor",
					  "envato-elements",
					  "wordfence",
					  "redirection",
					  "really-simple-ssl",
					  "post-smtp",
					  "imagify",
					  "wps-hide-login");

	for wp_plugin in "${wp_plugins[@]}"; do
	   printf "Installing ${wp_plugin} ....\n";
	   wp plugin install ${wp_plugin} --activate --allow-root;
	done
}

function wp_install_themes() {
	# Install new site theme and activate
	local wp_themes=("hello-elementor");

	for wp_theme in "${wp_themes[@]}"; do
	   printf "Installing ${wp_theme} ....\n";
	   wp theme install ${wp_theme} --activate --allow-root;
	done
}

function default_permissions {
	if [ ! -d ${SITE_BAK} ]; then
	 sudo mkdir -p ${SITE_BAK}
	fi

	# Understand Bitnami WordPress Filesystem Permissions
	# https://docs.bitnami.com/google/apps/wordpress/administration/understand-file-permissions/
	sudo chown -R bitnami:daemon ${SITE_DIR};
	sudo find ${SITE_DIR} -type d -exec chmod 775 {} \;
	sudo find ${SITE_DIR} -type f -exec chmod 664 {} \;
	sudo chmod 640 ${SITE_DIR}/wp-config.php;

	# Verify backup directory permissions
	sudo chown -R bitnami:daemon ${SITE_BAK};
	sudo chmod -Rf 775 ${SITE_BAK};

    if [ ! -d ${SITE_BAK} ]; then
        sudo mkdir -p ${SITE_BAK}
    fi

    # Verify backup directory permissions
    sudo chown -R bitnami:daemon ${SITE_BAK};
    sudo chmod -Rf 775 ${SITE_BAK};
}

function write_permissions {
    # Use it only for setup and update Wordfance plugin
    sudo chown -R bitnami:daemon ${SITE_DIR};
    sudo find ${SITE_DIR} -type d -exec chmod 775 {} \;
    sudo find ${SITE_DIR} -type f -exec chmod 664 {} \;

    if [ -d "${SITE_DIR}/wp-content/wflogs/" ]; then
        sudo chmod -Rf 775 ${SITE_DIR}/wp-content/wflogs/;
    fi

    if [ -f "${SITE_DIR}/wp-config.php" ]; then
        sudo chmod 775 ${SITE_DIR}/wp-config.php;
    fi

    if [ -f "${SITE_DIR}/wordfence-waf.php" ]; then
        sudo chmod 775 ${SITE_DIR}/wordfence-waf.php;
    fi

    if [ -f "${SITE_DIR}/wflogs/config-synced.php" ]; then
        sudo chmod 775 ${SITE_DIR}/wflogs/config-synced.php;
    fi


    if [ -f "${SITE_DIR}/.user.ini" ]; then
        sudo chmod 775 ${SITE_DIR}/.user.ini;
    fi

    if [ ! -d ${SITE_BAK} ]; then
        sudo mkdir -p ${SITE_BAK}
    fi

    # Verify backup directory permissions
    sudo chown -R bitnami:daemon ${SITE_BAK};
    sudo chmod -Rf 775 ${SITE_BAK};

}

function nginx_config_test(){
	sudo nginx -t && sudo /opt/bitnami/ctlscript.sh restart
}

function update_crontab(){
    export VISUAL="nano"
    local CRON_DIR=/opt/wp248/setup
	#write out current crontab
	echo "cron 1:"${CRON_DIR}/root_cron.${DATESTAMP};
	if !(sudo crontab -l > ${CRON_DIR}/root_cron.${DATESTAMP}); then
		echo "Root cron is empty"
	fi
	#echo new cron into cron file
	echo "cron 2:"${CRON_DIR}/crontab-user-root.mod;
	echo "cron 3:"${CRON_DIR}/root_cron.${DATESTAMP};

	cat ${CRON_DIR}/crontab-user-root.mod >> ${CRON_DIR}/root_cron.${DATESTAMP}

	#install new cron file
	echo "cron 3:" ${CRON_DIR}/root_cron.${DATESTAMP}

	sudo crontab ${CRON_DIR}/root_cron.${DATESTAMP}
}

# TODO: Add SSL setup using armeters from command line
echo "step 1 - Start"
sudo apt install memcached -y
sudo apt install locate -y
sudo apt install telnet -y
sudo apt install git -y
sudo updatedb

echo "step 2 - Start"
disable_banner

echo "step 3 - Start"
setup_modify_php

echo "step 4 - Start"
setup_ssl

echo "step 5 - Start"

write_permissions

echo "step 6 - Start"
default_permissions

echo "step 7 - Start"
wp_install_plugins

echo "step 8 - Start"
wp_install_themes

echo "step 9 - Start"
sudo nginx -t && sudo /opt/bitnami/ctlscript.sh restart php-fpm nginx

echo "step 10 - final setting wp config"

write_permissions
wp config set DISABLE_WP_CRON true
wp config set WP_SITEURL "https://{CRT_PRIMARY_DOMAIN}/"
wp config set WP_HOME "https://{CRT_PRIMARY_DOMAIN}/"

wp config get
