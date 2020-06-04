#!/usr/bin/env bash
#!/usr/bin/env bash

# Bitnami default wordpress doc root
SITE_DIR=/opt/bitnami/apps/wordpress/htdocs/

# Backup directory, we recommend it to be outside of HTTP root directory
BACKUP_PATH=/opt/bitnami/apps/wordpress/wp-update-backups/

# Date stamp to used in all renames, backup, log files
DATESTAMP=$(date +"%Y%m%d-%H%M%S")

TODAY=$(date +"%Y-%m-%d")
DAILY_DELETE_NAME="daily-"`date +"%Y-%m-%d" --date '7 days ago'`
WEEKLY_DELETE_NAME="weekly-"`date +"%Y-%m-%d" --date '5 weeks ago'`
MONTHLY_DELETE_NAME="monthly-"`date +"%Y-%m-%d" --date '12 months ago'`

WP_CLI_DIR=/opt/bitnami/apps/wordpress/bin

function db_backup(){
	local db_name db_date db_file

	db_name=$(${WP_CLI_DIR}/wp config get --constant=DB_NAME --path="${SITE_DIR}" --allow-root)
	db_file="${BACKUP_PATH}/db/${db_name}-${DATESTAMP}.sql"

	printf "Creating a backup of the %s database %s updating...\r\n" "$db_name"
	${WP_CLI_DIR}/wp db export "$db_file" --path="${SITE_DIR}" --allow-root

	gzip -9 ${db_file}
}

function make_database_backup(){
	local prefix=$1
	local db_name db_date db_file

	db_name=$(${WP_CLI_DIR}/wp config get --constant=DB_NAME --path="$CURRENT_PATH" --allow-root)
	db_date=$(date +"%Y-%m-%d")
	db_file="wp-update-${prefix}-${db_date}.sql"

	for f in "$BACKUP_PATH/wp-update-${prefix}-"*.sql; do
		if is_file "$f"; then
			printf "Removing a previous database backup file...\n"
			rm "$f"
		fi
		break
	done

	printf "Creating a backup of the %s database %s updating...\n" "$db_name" "$prefix"
	${WP_CLI_DIR}/wp db export "$db_file" --path="$CURRENT_PATH" --allow-root

	mv "$db_file" "$BACKUP_PATH/$db_file"

	if ! is_file "$BACKUP_PATH/$db_file"; then
		printf "Failed to create a database backup file in: %s\n%s\n" "$BACKUP_PATH" "$QUIT_MSG"
		exit 1
	fi

	if ! [[ -s "$BACKUP_PATH/$db_file" ]]; then
		printf "\Database backup file is empty in: %s\n%s\n" "$BACKUP_PATH" "$QUIT_MSG"
		exit 1
	fi

	DATABASE_BACKUP=true
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

    if [ -f "${SITE_DIR}/.user.ini" ]; then
        sudo chmod 775 ${SITE_DIR}/.user.ini;
    fi

    if [ ! -d ${BACKUP_PATH} ]; then
        sudo mkdir -p ${BACKUP_PATH}
    fi

    if [ ! -d ${BACKUP_PATH}/db ]; then
        sudo mkdir -p ${BACKUP_PATH}/db
    fi

    # Verify backup directory permissions
    sudo chown -R bitnami:daemon ${BACKUP_PATH};
    sudo chmod -Rf 775 ${BACKUP_PATH};


}

# Wordfance and Other secuirty plugins often changing secuirty  automatic ,
# this create problems to run ${WP_CLI_DIR}/wp commands

printf "=========[ START ${DATESTAMP} ]=========\r\n"
printf "Fixing write permision for updates \r\n"
write_permissions

printf "Db Backup\r\n";
db_backup

# We have to make sure Write permision in place
/opt/wp248/wp-update/wp-update.sh ${SITE_DIR} --all

printf "=========[ END ${DATESTAMP} ]=========\r\n"
