# wp248-maintain-system
Collection of scripts to support during the setup of WordPress sites, but mostly for system maintenance.

``

New setup version:
```
wget https://github.com/wp248/wp248-maintain-system/archive/master.zip
unzip master.zip
```


## NGINX ONLY - WARNING this is NOT APACHE2 setup

```
sudo cp -Rf ~/wp248-maintain-system-master/bitnami-stack/nginx/opt/* /opt/


sudo chown -R bitnami:daemon /opt/wp248
chmod +x /opt/wp248/wp-update/*.sh
chmod +x /opt/wp248/scripts/*.sh

# General add scripts to the path
/opt/wp248/scripts/adding-scripts-path.sh

# Define server param on .env file
cp /opt/wp248/scripts/conf/env.example /opt/wp248/scripts/conf/.env

# edit the enviroments file
nano /opt/wp248/scripts/conf/.env

# General updates and install modules
/opt/wp248/scripts/setup-and-run-once.sh

# Fix nginx
/opt/wp248/scripts/setup-and-run-once-nginx.sh

# Updateding crontab
/opt/wp248/scripts/setup-and-run-once-crontab.sh

# Verify back directory and secuirty:
sudo mkdir -p /opt/bitnami/apps/wordpress/wp-update-backups/db/
sudo chown -R bitnami:daemon /opt/bitnami/apps/wordpress/wp-update-backups/db/
/opt/wp248/scripts/wp-fix-write-permission.sh

# Listing Certificates
sudo ls -lah /opt/bitnami/letsencrypt/certificates

```

## APACHE2 ONLY - WARNING this is NOT NGINX setup

```
sudo cp -Rf ~/wp248-maintain-system-master/bitnami-stack/apache2/opt/* /opt/
```

Setup process TBD


## Installing redis - bitnami NGINX configuration

Install redis server
```
/opt/wp248/scripts/wp-install-redis.sh
```

Edit redis config
```
sudo nano /etc/redis/redis.conf
```
redis config search and replace 1:
```
>> Search for:
supervised

>> Change to:
supervised systemd
```
redis config search and replace 2:
```
>> Search for:
# maxmemory-policy

>> Replace or Add after:
maxmemory-policy allkeys-lru
```

redis config search and replace 3:

Notes:
* Securing your redis command from external attack
* you can skip this for stand setup
```
>> Search for:
rename-command CONFIG ""

>> Add after:

#rename-command FLUSHDB ""
#rename-command FLUSHALL ""
rename-command DEBUG ""
rename-command SHUTDOWN WP248_SHUTDOWN
rename-command CONFIG WP248_CONFIG
```
redis config search and replace 4:

Notes:
* this parm based on your server configuration and free memory
* Skip this config if you are not sure
```
>> Search for:
# maxmemory <bytes>

>> Add after / replace if not comments:
maxmemory 256mb
```

Restart services
```
sudo systemctl restart redis
```
Test redis
```
redis-cli ping

# should return:
# PONG
```

Update php.ini and restart service
```
sudo pecl install redis
sudo nano /opt/bitnami/php/etc/php.ini
sudo /opt/bitnami/ctlscript.sh restart php-fpm nginx
sudo systemctl restart redis
```
Add wordpress config for redis

Notes:
* we adding [_] (underscore to the end at the domain name)
* the underscore at the end of the domain will help to see the right parm
```
cd /opt/bitnami/apps/wordpress/htdocs/
wp config set WP_CACHE_KEY_SALT YOURDOMAIN.COM_
wp plugin install redis-cache --activate
```

