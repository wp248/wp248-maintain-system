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

		CRT_DOMAINS+=$(printf "%s"  " --domains=${DOMAINS[$i]}")
		CRT_DOMAINS+=$(printf "%s"  " --domains=www.${DOMAINS[$i]}")

		NGX_DOMAINS+=$(printf "%s"  " *.${DOMAINS[$i]}")
		NGX_DOMAINS+=$(printf "%s"  " ${DOMAINS[$i]}")

		if [[ "$PRIMARY_DOMAIN" != "${DOMAINS[$i]}" ]]; then
			NGX_DOMAINS_WITHOUT_PRIMARY+=$(printf "%s"  " *.${DOMAINS[$i]}")
			NGX_DOMAINS_WITHOUT_PRIMARY+=$(printf "%s"  " ${DOMAINS[$i]}")
		else
			NGX_DOMAINS_WITHOUT_PRIMARY+=$(printf "%s"  " *.${DOMAINS[$i]}")
		fi
	done
}

function renew_ssl()
{

	# Stop Service
	printf " >> Stoping nginx service\n";
	sudo /opt/bitnami/ctlscript.sh stop nginx

	printf " >> Stoping requesting new certificates\n";
	sudo /opt/bitnami/letsencrypt/lego --http --tls --accept-tos --email="${CRT_EMAIL}" ${CRT_DOMAINS} \
									   --path="/opt/bitnami/letsencrypt" renew
	# Restart Service
	sudo /opt/bitnami/ctlscript.sh start nginx

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
printf "===========\n > CRT_DOMAINS: %s\n" "$CRT_DOMAINS"


printf "Step 02.01: Verify tmp directory\n";
if ! [ -d "${DIR}/tmp/" ]; then
	sudo mkdir -p $DIR/tmp
    sudo chown -R bitnami:daemon ${DIR}/tmp/;
    sudo chmod -Rf 775 ${DIR}/tmp/;
fi

renew_ssl
#sudo nginx -t && sudo /opt/bitnami/ctlscript.sh restart php-fpm nginx


