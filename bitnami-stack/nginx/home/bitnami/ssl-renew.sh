#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e

CRT_EMAIL=webmaster@yoursite.com
CRT_PRIMARY_DOMAIN=yoursite.com
CRT_SECONDARY_DOMAIN=www.yoursite.com


function renew_ssl() {
	local CRT_DIR=/opt/bitnami/nginx/conf
	local LET_DIR=/opt/bitnami/letsencrypt/certificates

	# Stop Service
	sudo /opt/bitnami/ctlscript.sh stop nginx

	sudo /opt/bitnami/letsencrypt/lego --http --tls --accept-tos --email="${CRT_EMAIL}"\
									   --domains="${CRT_PRIMARY_DOMAIN}" \
									   --domains="${CRT_SECONDARY_DOMAIN}" \
									   --path="/opt/bitnami/letsencrypt" renew

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

# TODO: Check if ssl already issue before starting the process

# TODO: Adding SSL crontab to renew (minimum two month)
#		Chalanages: How many times to cycle the script? How to verify before stoping services. Minimum cycle time?

renew_ssl
