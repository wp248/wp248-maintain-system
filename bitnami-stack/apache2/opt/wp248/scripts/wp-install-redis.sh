#!/usr/bin/env bash
sudo apt update
sudo apt install redis-server -y
sudo apt-get -y install gcc make autoconf libc-dev pkg-config

sudo nano /etc/redis/redis.conf

Search for:
supervised
Change to:
supervised systemd

Search for:
rename-command CONFIG ""

after add:

#rename-command FLUSHDB ""
#rename-command FLUSHALL ""
rename-command DEBUG ""
rename-command SHUTDOWN WP248_SHUTDOWN
rename-command CONFIG WP248_CONFIG


Search for:
# maxmemory <bytes>

Add:
maxmemory 256mb


Search for:
# maxmemory-policy
Replace/add to:
maxmemory-policy allkeys-lru

sudo systemctl restart redis

redis-cli
ping
pong

sudo pecl install redis
sudo nano /opt/bitnami/php/etc/php.ini
sudo /opt/bitnami/ctlscript.sh restart php-fpm nginx
sudo systemctl restart redis

cd /opt/bitnami/apps/wordpress/htdocs/
wp config set WP_CACHE_KEY_SALT tutors.kidsontheyard.com_
wp plugin  install redis-cache --activate

# the underscore at the end of the domain will help to see the right parm


install Redis plugin

   43  sudo systemctl status redis
   44  redis-cli
   45  sudo systemctl restart redis
   46  redis-cli
   47  sudo systemctl restart redis
   48  redis-cli
   49  sudo nano /etc/redis/redis.conf
   50  sudo netstat -lnp | grep redis
   51  sudo nano /etc/redis/redis.conf
   52  sudo systemctl restart redis.service
   53  redis-cli
   54  sudo nano  /etc/redis/redis.conf
   55  sudo systemctl restart redis
   56  redis-cli
   57  sudo nano  /etc/redis/redis.conf
   58  sudo systemctl restart redis
   59  redis-cli
   60  restart
   61  sudo shutdown -r now
   62  redis-cli
   63  sudo nano  /etc/redis/redis.conf
   64  sudo systemctl restart redis
   65  redis-cli
   66  sudo nano  /etc/redis/redis.conf
   67  sudo apt-get -y install gcc make autoconf libc-dev pkg-config
   68  sudo pec sp install redis
   69  sudo pec-sp install redis
   70  sudo locate pec
   71  sudo pecl
   72  sudo pecl-sp
   73  sudo pecl install redis
   74  sudo nano /opt/bitnami/php/etc/php.ini
   75  sudo /opt/bitnami/ctlscript.sh restart php-fpm nginx
   76  php -m
   77  php -m | grep re
   78  history
