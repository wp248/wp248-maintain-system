# wp248-maintain-system
Collection of scripts to support during the setup of WordPress sites, but mostly for system maintenance.

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


cp /opt/wp248/scripts/conf/env.example /opt/wp248/scripts/conf/.env

# Modify the enviroments file
nano /opt/wp248/scripts/conf/.env



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

