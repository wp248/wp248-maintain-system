#!/usr/bin/env bash

# Disable Banner
sudo /opt/bitnami/apps/wordpress/bnconfig --disable_banner 1

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
