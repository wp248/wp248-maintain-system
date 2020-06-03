#!/usr/bin/env bash

SITE_DIR=/opt/bitnami/apps/wordpress/htdocs/
SITE_BAK=/opt/bitnami/apps/wordpress/wp-update-backups/


# =============================================================================
# Functions
# =============================================================================

function is_file() {
	local file=$1
	[[ -f $file ]]
}

function is_dir() {
	local dir=$1
	[[ -d $dir ]]
}


if [ ! -d ${SITE_BAK} ]; then
 sudo mkdir -p ${SITE_BAK}
fi

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

#default_permissions;
write_permissions;
