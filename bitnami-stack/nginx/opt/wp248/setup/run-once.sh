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

	sudo cat php.mod >>  ${PHP_DIR}/php.ini
}

function wp_install_plugins() {
	# Install new site plugins and activate
	local wp_plugins=("elementor",
					  "envato-elements",
					  "wordfence",
					  "redirection",
					  "really-simple-ssl",
					  "post-smtp",
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

}

function nginx_config_test(){
	sudo nginx -t && sudo /opt/bitnami/ctlscript.sh restart
}

function update_crontab(){
	#write out current crontab
	sudo crontab -l > root_cron.${DATESTAMP}
	#echo new cron into cron file
	echo crontab-user-root.mod root_cron.${DATESTAMP}

	#install new cron file
	crontab root_cron.${DATESTAMP}
}

# TODO: Add SSL setup using armeters from command line
sudo apt install memcached -y
sudo apt install locate -y
sudo updatedb

disable_banner
setup_modify_php
setup_ssl
update_crontab
default_permissions
wp_install_plugins
wp_install_themes
