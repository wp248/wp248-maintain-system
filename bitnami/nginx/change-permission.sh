#!/usr/bin/env bash

SITE_DIR=/opt/bitnami/apps/wordpress/htdocs/
SITE_BAK=/opt/bitnami/apps/wordpress/wp-update-backups/


if [ ! -d ${SITE_BAK} ]; then
 sudo mkdir -p ${SITE_BAK}
fi


function default_permissions {
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

function write_permissions {
	# Use it only for setup and update Wordfance plugin
	sudo chown -R bitnami:daemon ${SITE_DIR};
	sudo find ${SITE_DIR} -type d -exec chmod 775 {} \;
	sudo find ${SITE_DIR} -type f -exec chmod 664 {} \;
	sudo chmod 775 ${SITE_DIR}/wp-config.php;
	sudo chmod 775 ${SITE_DIR}/wordfence-waf.php;
	sudo chmod 775 ${SITE_DIR}/.user.ini;
	sudo chmod -Rf 775 ${SITE_DIR}/wp-content/wflogs/;

	# Verify backup directory permissions
	sudo chown -R bitnami:daemon ${SITE_BAK};
	sudo chmod -Rf 775 ${SITE_BAK};

}

default_permissions;
