#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Default php.ini
PHP_DIR=/opt/bitnami/php/etc

# Date stamp to used in all renames, backup, log files
readonly DATESTAMP=$(date +"%Y%m%d-%H%M%S")

#
export VISUAL="nano"


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

function setup_modify_php() {
	#local PHP_DIR=/opt/bitnami/php/etc

	# Create Backup
	sudo cp ${PHP_DIR}/php.{ini,backup.${DATESTAMP}}

	sudo cat ${PHP_DIR}/php.mod >>  ${PHP_DIR}/php.ini
}


function bash_apt_update() {
	# bash_apt_update
	sudo apt-get update -y && sudo apt-get upgrade -y
	sudo apt install memcached -y
	sudo apt install locate -y
	sudo apt install telnet -y
	sudo apt install git -y
	sudo apt install rsync -y
	sudo apt install mosh -y

	# Image procssing uils
	sudo apt install libjpeg-progs  jpegoptim gifsicle optipng pngquant webp -y

	sudo updatedb
}

# Disable Banner
disable_banner
bash_apt_update

