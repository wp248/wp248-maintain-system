# wp248-maintain-system
Collection of scripts to support during the setup of WordPress sites, but mostly for system maintenance.
# Table of Contents
* [Download lates version](#setup)
* [NGINX Instructions](#nginx)
* [APACHE2 Instructions](#apach2)
* [redis server on NGINX](#redis-nginx)
* [WordPress related tweaks for bitnami](#wordpress)
    - [Define domain name for CLI](#cli-domain-name)
    - [Disable all debugs errors](#wp-debug-off)
    - [Enable all debugs errors](#wp-debug-on)
    - [Rename default admin user](#wp-rename-admin)

## Download the latest version:<a name="setup" />
```
wget https://github.com/wp248/wp248-maintain-system/archive/master.zip
unzip master.zip
```


## NGINX Setup instructions<a name="nginx" />
> :warning: this is NOT APACHE2 setup


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

## APACHE2 Setup instructions<a name="apach2" />
> :warning: this is NOT NGINX setup

### Download the latest version:<a name="setup" />
```
wget https://github.com/wp248/wp248-maintain-system/archive/master.zip
unzip master.zip
```




```
sudo cp -Rf ~/wp248-maintain-system-master/bitnami-stack/apache2/opt/* /opt/

sudo chown -R bitnami:daemon /opt/wp248
chmod +x /opt/wp248/wp-update/*.sh
chmod +x /opt/wp248/scripts/*.sh

# General add scripts to the path
/opt/wp248/scripts/adding-scripts-path.sh


sudo /opt/bitnami/apps/wordpress/bnconfig --disable_banner 1

/opt/wp248/scripts/install-first-step1.sh

/opt/wp248/scripts/update.sh
```

Setup process TBD


## Installing redis on Nginx <a name="redis-nginx" />
> :warning: this is NGINX setup for bitnami stack, but can be used as guideline for other installs

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

## WordPress related tweaks for bitnami:<a name="wordpress" />

### Define domain name for CLI:<a name="cli-domain-name" />
```
sudo nano /opt/bitnami/apps/wordpress/htdocs/wp-config.php
```
search for:
```
if ( defined( 'WP_CLI' ) ) {
    $_SERVER['HTTP_HOST'] = 'localhost';
}
```
replace with:
```
if ( defined( 'WP_CLI' ) ) {
    $_SERVER['HTTP_HOST'] = 'YOUR-DOMAIN-NAME.COM';
}

```
### Disable all debugs errors:<a name="wp-debug-off" />
Add the following lines before:

/* That's all, stop editing! Happy publishing. */
```
ini_set('display_errors','Off');
ini_set('error_reporting', E_ALL );
define('WP_DEBUG', false);
define('WP_DEBUG_DISPLAY', false);
```
### Enable all debugs errors:<a name="wp-debug-on" />
Add the following lines before:

/* That's all, stop editing! Happy publishing. */
```
ini_set('display_errors','On');
ini_set('error_reporting', E_ALL );
define('WP_DEBUG', true);
define('WP_DEBUG_DISPLAY', true);
// comment this out to change the default error log locations
//define( 'WP_DEBUG_LOG', '/opt/bitnami/apps/wordpress/log/wp-errors.log' );
define( 'SCRIPT_DEBUG', true );

```

```
wp config set WP_DEBUG_LOG '/opt/bitnami/apps/wordpress/log/wordpress-errors.log'
```

### Rename default admin user:<a name="wp-rename-admin" />

```
mysql -p -u bn_wordpress bitnami_wordpress

update wp_users  set user_email='webmaster@DOMAIN.com'  where user_login='user';
update wp_users  set user_login='NEW-USER-ID' where user_login='user';

```
