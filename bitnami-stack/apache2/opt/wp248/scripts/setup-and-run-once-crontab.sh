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

function update_crontab(){

    local CRON_DIR="${DIR}/conf/"

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
printf "=========[ START crontab ${DATESTAMP} ]=========\r\n"

update_crontab
