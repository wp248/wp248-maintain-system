# wp248-maintain-system
Collection of scripts to support during the setup of WordPress sites, but mostly for system maintenance.

./nginx
./nginx/setup - Used only during the setup time.

# Usefull commands

DISABLE_WP_CRON
wp config set DISABLE_WP_CRON true

Remmber:
after changing php.ini need to restart both services
sudo /opt/bitnami/ctlscript.sh restart php-fpm nginx

```
wget https://github.com/wp248/wp248-maintain-system/archive/master.zip
unzip master.zip
sudo cp -Rf ~/wp248-maintain-system-master/bitnami-stack/nginx/home/bitnami/* ~/
sudo cp -Rf ~/wp248-maintain-system-master/bitnami-stack/nginx/opt/* /opt/
sudo chown -R bitnami:daemon /opt/wp248

~/update.sh


nano /opt/wp248/setup/run-once.sh
```
Fix the following parm

```
CRT_EMAIL=webmaster@limitlessv.com
CRT_PRIMARY_DOMAIN=speed1.limitlessv.com
CRT_SECONDARY_DOMAIN=www.speed1.limitlessv.com
```

Run the setup
``
/opt/wp248/setup/run-once.sh
``

Verify SSL installed correctly

``
ls -lah /opt/bitnami/nginx/conf/
``

fixing it using:
``
sudo ln /opt/bitnami/letsencrypt/certificates/sample.com.key /opt/bitnami/nginx/conf/server.key
sudo ln /opt/bitnami/letsencrypt/certificates/sample.limitlessv.com.crt /opt/bitnami/nginx/conf/server.crt
``

Changing Permissions:

``
sudo nano ~/change-permission.sh
~/change-permission.sh

``

New setup version:
```
wget https://github.com/wp248/wp248-maintain-system/archive/master.zip
unzip master.zip
sudo cp -Rf ~/wp248-maintain-system-master/bitnami-stack/nginx/home/bitnami/* ~/
sudo cp -Rf ~/wp248-maintain-system-master/bitnami-stack/nginx/opt/* /opt/

sudo chown -R bitnami:daemon /opt/wp248
chmod +x /opt/wp248/wp-update/*.sh
chmod +x /opt/wp248/scripts/*.sh

/opt/wp248/scripts/adding-scripts-path.sh


cp /opt/wp248/script/conf/env.example /opt/wp248/script/conf/.env

# Modify the enviroments file
nano /opt/wp248/script/conf/.env



# execute script

# General pdated
/opt/wp248/scripts/setup-and-run-once.sh

Fix nginx
/opt/wp248/scripts/setup-and-run-once-nginx.sh

Updateding crontab
/opt/wp248/scripts/setup-and-run-once-crontab.sh


Verify:
sudo mkdir -p /opt/bitnami/apps/wordpress/wp-update-backups/db/
sudo chown -R bitnami:daemon /opt/bitnami/apps/wordpress/wp-update-backups/db/

```

