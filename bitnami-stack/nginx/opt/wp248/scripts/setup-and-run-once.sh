#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e

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


function disable_banner() {
	# Disable Banner
	sudo /opt/bitnami/apps/wordpress/bnconfig --disable_banner 1
}

function bash_apt_update() {
	sudo apt-get update -y && sudo apt-get upgrade -y
	sudo apt install memcached -y
	sudo apt install locate -y
	sudo apt install telnet -y
	sudo apt install git -y
	sudo updatedb
}

function prep_domain() {

	#printf "%s\n"  " --domains=${DOMAINS[$@]}"
	for i in ${!DOMAINS[@]};
	do

		CRT_DOMAINS+=$(printf "%s"  " --domains=${DOMAINS[$i]}")
		NGX_DOMAINS+=$(printf "%s"  " ${DOMAINS[$i]}")
		NGX_DOMAINS+=$(printf "%s"  " *.${DOMAINS[$i]}")
	done
}

function disable_banner() {
	# Disable Banner
	sudo /opt/bitnami/apps/wordpress/bnconfig --disable_banner 1
}

function setup_modify_php() {
	local PHP_DIR=/opt/bitnami/php/etc

	# Create Backup
	sudo cp ${PHP_DIR}/php.{ini,backup.${DATESTAMP}}

	sudo cat ${PHP_DIR}/php.mod >>  ${PHP_DIR}/php.ini
}


function setup_ssl() {

	# Stop Service
	sudo /opt/bitnami/ctlscript.sh stop nginx

	sudo /opt/bitnami/letsencrypt/lego --http --tls --accept-tos --email="${CRT_EMAIL}" ${CRT_DOMAINS} \
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

}

function wp_install_plugins() {
	# Install new site plugins and activate
	local wp_plugins=("elementor",
					  "envato-elements",
					  "wordfence",
					  "ele-custom-skin",
					  "custom-post-type-ui",
					  "advanced-custom-fields",
					  "google-site-kit",
					  "seo-by-rank-math",
					  "envato-elements"
					  "post-smtp",
					  "imagify",
					  "wps-hide-login");
# Removed from the list
#					  "redirection",
#					  "really-simple-ssl",

	for wp_plugin in "${wp_plugins[@]}"; do
	   printf " >> Installing ${wp_plugin} ....\n";
	   ${WP_CLI_PATH}/wp plugin install ${wp_plugin} --activate --path="${WP_SITE_ROOT}" --allow-root;
	done
}


function wp_deactivate_plugins() {
	# Install new site plugins and activate
	local wp_plugins=("akismet",
					  "all-in-one-seo-pack",
					  "all-in-one-wp-migration",
					  "google-analytics-for-wordpress",
					  "jetpack",
					  "simple-tags",
					  "wp-mail-smtp");

	for wp_plugin in "${wp_plugins[@]}"; do
	   printf " >> deactivate ${wp_plugin} ....\n";
	   ${WP_CLI_PATH}/wp plugin deactivate ${wp_plugin} --activate --path="${WP_SITE_ROOT}" --allow-root;
	   printf " >> delete ${wp_plugin} ....\n";
	   ${WP_CLI_PATH}/wp plugin delete ${wp_plugin} --activate --path="${WP_SITE_ROOT}" --allow-root;
	done
}





function wp_install_themes() {
	# Install new site theme and activate
	local wp_themes=("hello-elementor");

	for wp_theme in "${wp_themes[@]}"; do
	   printf "Installing ${wp_theme} ....\n";
	   ${WP_CLI_PATH}/wp theme install ${wp_theme} --activate --path="${WP_SITE_ROOT}" --allow-root;
	done
}
# =============================================================================
# Variables
# =============================================================================
printf "Step 01.00: Variables and Config\n";

# All unique CLI argument options in the right order
ALLOPTIONS=()

QUIT_MSG="Stopping script executions..."

ENV_FILE=".env"

SOURCE="${BASH_SOURCE[0]}"

CRT_DOMAINS=''
NGX_DOMAINS=''

while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# =============================================================================
# Options
# =============================================================================

printf "Step 01.01: Variables and Config options\n";

ARGUMENT_COUNT=$((ARGUMENT_COUNT + 1))
for arg in "$@"
do
	ALLOPTIONS+=($arg);
	if [[ "$ARGUMENT_COUNT" = 1 ]]; then
		DIR=$arg;
	fi
done

CONF_FILE="${DIR}/conf/${ENV_FILE}"

 printf "===========\n > Using: %s\n" "$CONF_FILE"

# Check env files found
if ! is_file "$CONF_FILE"; then
	printf ">> Failed to load seting files: %s\n%s\n" "$CONF_FILE" "$QUIT_MSG"
	exit 1
fi

# Use the param files
source "${CONF_FILE}";

printf "Step 02.00: Prepare domains list for certificates and nginx config\n";
prep_domain

printf "Step 02.01: Prepare domains list for certificates and nginx config\n";
printf "===========\n > PRIMARY_DOMAIN: %s\n" "PRIMARY_DOMAIN"
printf "===========\n > CRT_DOMAINS: %s\n" "$CRT_DOMAINS"
printf "===========\n > NGX_DOMAINS: %s\n" "$NGX_DOMAINS"

printf "Step 03.00: update bash and install missing components\n";

bash_apt_update

printf "Step 04.00: Disable bitnami banner\n";
disable_banner

printf "Step 05.00: setup_modify_php\n";
setup_modify_php

printf "Step 05.00: setup ssl\n";
setup_ssl

printf "Step 06.00: Fixing site to write permissions\n";
if [ -f "${DIR}/wp-fix-write-permission.sh" ]; then
	source "${DIR}/wp-fix-write-permission.sh"
else
	printf "===========\n > write permission failed file: %s not found\n" "${DIR}/wp-fix-write-permission.sh"
fi

printf "Step 07.00: update wordpress configs\n";
${WP_CLI_PATH}/wp config set DISABLE_WP_CRON true --path="${WP_SITE_ROOT}" --allow-root;
${WP_CLI_PATH}/wp config set WP_SITEURL "https://{PRIMARY_DOMAIN}/" --path="${WP_SITE_ROOT}" --allow-root;
${WP_CLI_PATH}/wp config set WP_HOME "https://{PRIMARY_DOMAIN}/" --path="${WP_SITE_ROOT}" --allow-root;
${WP_CLI_PATH}/wp config get --path="${WP_SITE_ROOT}" --allow-root;


printf "Step 07.01: Deactivate default plugin\n";
wp_deactivate_plugins

printf "Step 07.02: Install & activate a list of plugins\n";
wp_install_plugins


printf "Step 08.00: Install themes\n";
wp_install_themes

printf "Step 09.00: Fixing site to write permissions after plugin install and activate\n";
if [ -f "${DIR}/wp-fix-write-permission.sh" ]; then
	source "${DIR}/wp-fix-write-permission.sh"
else
	printf "===========\n > write permission failed file: %s not found\n" "${DIR}/wp-fix-write-permission.sh"
fi

write_permissions

printf "Step 010.00: restart services\n";
sudo nginx -t && sudo /opt/bitnami/ctlscript.sh restart php-fpm nginx

