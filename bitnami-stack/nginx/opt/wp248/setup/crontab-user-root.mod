
# Wordpress Keep internal cron updated instead trigger it when page load.
*/15 * * * * su daemon -s /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/php/bin/php -q wp-cron.php"

# Wordpress Keep Plugin updated - using only wp no backup
#18 8 * * * su daemon -s /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/apps/wordpress/bin/wp plugin update --all"
#28 8 * * * su daemon -s /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/apps/wordpress/bin/wp theme update --all"

# Wordpress Backup and Keep all updates
10 8 * * * /opt/wp248/cron-4-wp-updates.sh> /dev/null
#10 8 * * * /opt/wp248/cron-4-wp-updates.sh>>/opt/bitnami/apps/wordpress/wp-update-backups/db/cron.log;


# Wordpress Keep it clean
10 7 * * * su daemon -s /bin/sh -c "find /opt/bitnami/apps/wordpress/htdocs/wp-content/cache/ -mtime +7 -delete"
15 7 * * * su daemon -s /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/apps/wordpress/bin/wp cache flush"
20 7 * * * su daemon -s /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/apps/wordpress/bin/wp cache clear"

# Plugin Specific: autoptimize - avoid cache size is getting big
# 24 2 * * * su daemon -s /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/apps/wordpress/bin/wp autoptimize clear"

# Plugin Specific: wordfance: Unable to open file for reading and writing.

