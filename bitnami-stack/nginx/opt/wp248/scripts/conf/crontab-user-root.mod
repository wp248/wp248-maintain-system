# -------------------------------------------------------------------------
# # Author: 101sam
# Github: https://github.com/101sam/wp248-maintain-system
#
# All Times assume system UTC and server locations PST
#                        USE (TZ=":America/Los_Angeles" date)
# Crontab syntax:
# * * * * * command to be executed
# - - - - -
# | | | | |
# | | | | +----- day of week (0 - 6) (Sunday=0)
# | | | +------- month (1 - 12)
# | | +--------- day of month (1 - 31)
# | +----------- hour (0 - 23)
# +------------- min (0 - 59)
#
# Useful examples:
#        every 5 min
#                 */5 * * * * CMD> /dev/null
#        twice a day (5AM and 5PM) using comma-separated
#                 0 5,17 * * * CMD> /dev/null
#        Use the condition for example every First Sunday of the month
#                 0 5 * * sun  [ $(date +%d) -le 07 ] && CMD> /dev/null
#        Using timestamp
#                 @yearly timestamp is similar to “0 0 1 1 *”
#                 @monthly timestamp is similar to “0 0 1 * *”
#                 @daily timestamp is similar to “0 0 * * *”
#                 @hourly timestamp is similar to “0 * * * *”
#        Using reboot is useful for those tasks which you want to run on your system startup.
#                 @reboot
# -------------------------------------------------------------------------



# Wordpress Keep internal cron updated instead trigger it when page load.
*/15 * * * * su daemon -s /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/php/bin/php -q wp-cron.php"

# Wordpress Backup and Keep all updates
10 8 * * * /opt/wp248/scripts/cron-wp-complete-update.sh /opt/wp248/scripts/conf> /dev/null
#10 8 * * * /opt/wp248/scripts/cron-wp-complete-update.sh /opt/wp248/scripts/conf>>/opt/bitnami/apps/wordpress/wp-update-backups/db/cron.log;

#15 8 * * * /opt/wp248/scripts/cron-wp-upd-plugins.sh /opt/wp248/scripts/conf> /dev/null
#20 8 * * * /opt/wp248/scripts/cron-wp-upd-themes.sh /opt/wp248/scripts/conf> /dev/null
#25 8 * * * /opt/wp248/scripts/cron-wp-upd-translations.sh /opt/wp248/scripts/conf> /dev/null


# Cleanup time Dont keep backup over 21 days
10 9 * * * find /opt/bitnami/apps/wordpress/wp-update-backups/db/ -mtime +21 -delete> /dev/null


# Wordpress Keep it clean
10 7 * * * su daemon -s /bin/sh -c "find /opt/bitnami/apps/wordpress/htdocs/wp-content/cache/ -mtime +7 -delete"
15 7 * * * su daemon -s /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/apps/wordpress/bin/wp cache flush --path="/opt/bitnami/apps/wordpress/htdocs" --allow-root"
20 7 * * * su daemon -s /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/apps/wordpress/bin/wp cache clear --path="/opt/bitnami/apps/wordpress/htdocs" --allow-root"

# Plugin Specific: autoptimize - avoid cache size is getting big
# 24 2 * * * su daemon -s /bin/sh -c "cd /opt/bitnami/apps/wordpress/htdocs/; /opt/bitnami/apps/wordpress/bin/wp autoptimize clear --path="/opt/bitnami/apps/wordpress/htdocs"  --allow-root"

# SSL update once in a month at:
0 0 1 * * /opt/wp248/scripts/cron-renew-ssl-certificates.sh /opt/wp248/scripts/conf> /dev/null

# Plugin Specific: wordfance: Unable to open file for reading and writing.
