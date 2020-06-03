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


function prep_domain() {

	for i in ${!DOMAINS[@]};
	do

		CRT_DOMAINS+=$(printf "%s"  " --domains=≈≈}")
		NGX_DOMAINS+=$(printf "%s"  " ${DOMAINS[$i]}")
		NGX_DOMAINS+=$(printf "%s"  " *.${DOMAINS[$i]}")


		if [[ "$PRIMARY_DOMAIN" != "${DOMAINS[$i]}" ]]; then
			NGX_DOMAINS_WITHOUT_PRIMARY+=$(printf "%s"  " ${DOMAINS[$i]}")
			NGX_DOMAINS_WITHOUT_PRIMARY+=$(printf "%s"  " *.${DOMAINS[$i]}")
		else
			NGX_DOMAINS_WITHOUT_PRIMARY+=$(printf "%s"  " *.${DOMAINS[$i]}")
		fi
	done
}

function step1(){
	# Create Backup for current config
	printf "Step 1.1: make backup  \r\n"
	if ! [ -f "/opt/bitnami/apps/wordpress/conf/nginx-app.conf" ]; then
		printf "config not found: %s\n%s\n" "/opt/bitnami/apps/wordpress/conf/nginx-app.conf" "$QUIT_MSG"
		exit 1
	fi
	sudo cp /opt/bitnami/apps/wordpress/conf/nginx-app.conf /opt/bitnami/apps/wordpress/conf/nginx-app.conf.${DATESTAMP}

	printf "Step 1.2: modify config  \r\n"
	if ! [ -f "/opt/bitnami/apps/wordpress/conf/wp248-cors.conf" ]; then
		printf "config not found: %s\n%s\n" "/opt/bitnami/apps/wordpress/conf/wp248-cors.conf" "$QUIT_MSG"
		exit 1
	fi
	if ! [ -f "/opt/bitnami/apps/wordpress/conf/nginx-app.conf" ]; then
		printf "config not found: %s\n%s\n" "/opt/bitnami/apps/wordpress/conf/nginx-app.conf" "$QUIT_MSG"
		exit 1
	fi
	echo "include \"/opt/bitnami/apps/wordpress/conf/wp248-cors.conf\";" >> /opt/bitnami/apps/wordpress/conf/nginx-app.conf
}

function step2(){
	printf "Step 2.1: make backup  \r\n"
	if ! [ -f "/opt/bitnami/nginx/conf/nginx.conf" ]; then
		printf "config not found: %s\n%s\n" "/opt/bitnami/nginx/conf/nginx.conf" "$QUIT_MSG"
		exit 1
	fi
	if ! [ -f "/opt/bitnami/nginx/conf/wp248-bitnami-nginx.conf" ]; then
		printf "config not found: %s\n%s\n" "/opt/bitnami/nginx/conf/wp248-bitnami-nginx.conf" "$QUIT_MSG"
		exit 1
	fi

	sudo cp /opt/bitnami/nginx/conf/nginx.conf /opt/bitnami/nginx/conf/nginx.conf.${DATESTAMP}

	printf "Step 2.2: modify config  \r\n"
	# Do remove the enter at the end , needed for CRLF
	sudo sed -i '\/include \"\/opt\/bitnami\/nginx\/conf\/bitnami\/bitnami.conf\"/i \
	include "\/opt\/bitnami\/nginx\/conf\/wp248-bitnami-nginx.conf\"; \
	'  /opt/bitnami/nginx/conf/nginx.conf

}

function step3(){
	printf "Step 3.1: make backup  \r\n"
	if ! [ -f "/opt/bitnami/nginx/conf/mime.types" ]; then
		printf "config not found: %s\n%s\n" "/opt/bitnami/nginx/conf/mime.types" "$QUIT_MSG"
		exit 1
	fi

	sudo mv /opt/bitnami/nginx/conf/mime.types /opt/bitnami/nginx/conf/mime.types.${DATESTAMP}
	printf "Step 3.2: modify config  \r\n"
	sudo cp /opt/bitnami/nginx/conf/mime.types.mod /opt/bitnami/nginx/conf/mime.types
}

function step4(){
	printf "Step 4.1: make backup  \r\n"
	sudo mv /opt/bitnami/nginx/conf/bitnami/bitnami.conf /opt/bitnami/nginx/conf/bitnami/bitnami.conf.${DATESTAMP}

	printf "Step 4.2: replacing config  \r\n"
	if ! [ -f "/opt/bitnami/nginx/conf/bitnami/bitnami.conf.mod" ]; then
		printf "config not found: %s\n%s\n" "/opt/bitnami/nginx/conf/bitnami/bitnami.conf.mod" "$QUIT_MSG"
		exit 1
	fi
	sudo sed 's/WP248_PRIMARY_DOMAIN/${PRIMARY_DOMAIN}/g' /opt/bitnami/nginx/conf/bitnami/bitnami.conf.mod  > "${DIR}/tmp/bitnami.conf.step1"


	printf "Step 4.3: replacing config  \r\n"
	if ! [ -f "${DIR}/tmp/bitnami.conf.step1" ]; then
		printf "config not found: %s\n%s\n" "${DIR}/tmp/bitnami.conf.step1" "$QUIT_MSG"
		exit 1
	fi

	sudo sed 's/WP248_NGX_DOMAINS/${NGX_DOMAINS}/g' "${DIR}/tmp/bitnami.conf.step1"  > "${DIR}/tmp/bitnami.conf.step2"

	printf "Step 4.4: replacing config  \r\n"
	if ! [ -f "${DIR}/tmp/bitnami.conf.step2" ]; then
		printf "config not found: %s\n%s\n" "${DIR}/tmp/bitnami.conf.step2" "$QUIT_MSG"
		exit 1
	fi

	sudo sed 's/WP248_NGX_DOMAINS_WITHOUT_PRIMARY/${NGX_DOMAINS_WITHOUT_PRIMARY}/g' ${DIR}/tmp/bitnami.conf.step2  > ${DIR}/tmp/bitnami.conf.step3

	printf "Step 4.5: replacing config  \r\n"
	sudo mv /opt/wp248/setup/bitnami.conf /opt/bitnami/nginx/conf/bitnami/bitnami.conf

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
NGX_DOMAINS_WITHOUT_PRIMARY=''

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
printf "===========\n > PRIMARY_DOMAIN: %s\n" "$PRIMARY_DOMAIN"
#printf "===========\n > CRT_DOMAINS: %s\n" "$CRT_DOMAINS"
printf "===========\n > NGX_DOMAINS: %s\n" "$NGX_DOMAINS"
printf "===========\n > NGX_DOMAINS_WITHOUT_PRIMARY: %s\n" "$NGX_DOMAINS_WITHOUT_PRIMARY"
prep_domain

printf "Step 02.01: Verify tmp directory\n";
if [ -d "${DIR}/tmp/" ]; then
	sudo mkdir -p "${DIR}/tmp/"
    sudo chown -R bitnami:daemon ${DIR}/tmp/;
    sudo chmod -Rf 775 ${DIR}/tmp/;
fi


printf "=========[ START nginx CONFIG ${DATESTAMP} ]=========\r\n"
printf "Step 1: Fixing /opt/bitnami/apps/wordpress/conf/nginx-app.conf \r\n"
step1

printf "Step 2: Fixing /opt/bitnami/nginx/conf/nginx.conf  \r\n"
step2

printf "Step 3: Fixing /opt/bitnami/nginx/conf/mime.types  \r\n"
step3
#
#
printf "Step 4: Fixing /opt/bitnami/nginx/conf/bitnami/bitnami.conf  \r\n"
step4

printf "Step 5: Test nginx config & restart services  \r\n"

sudo nginx -t && sudo /opt/bitnami/ctlscript.sh restart php-fpm nginx
printf "=========[ END nginx CONFIG ${DATESTAMP} ]=========\r\n"
