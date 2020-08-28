# --------------------------------------------------------------------------------------------------------
# BEGIN WP248 Changes
# --------------------------------------------------------------------------------------------------------
max_execution_time = 300
max_input_time = 400
max_input_vars = 10000
memory_limit = 512M
max_file_uploads = 20
upload_max_filesize = 1024M
post_max_size = 1024M

# Use 0 to the max suppported files size
#upload_max_filesize = 0
#post_max_size = 0


# Date Time
#date.timezone = "America/Los_Angeles"
#date.timezone = "UTC"

# zend_extension opcache tunining
opcache.memory_consumption = 192
opcache.fast_shutdown = 1
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 10000
opcache.revalidate_freq = 60

#Additional extension
#extension_dir = /opt/bitnami/php/lib/php/extensions
#extension=imagick.so
#extension=vips.so
#extension=redis.so
#extension = memcached.so

# --------------------------------------------------------------------------------------------------------
# Store PHP sessions in memcached
# By default PHP is using the disk; putting session data into memcached can speed up PHP significantly
# and also solves loadbalancing issues.
# You'll need to install the memcache PHP extension and replace the original lines with these in php.ini:
# --------------------------------------------------------------------------------------------------------

# Enable extension
#extension=memcached.so

[Session]
# Overwrite setting
#session.save_handler = memcached
#session.save_path = "tpc://127.0.0.1:11211"


# END WP248 Changes
# --------------------------------------------------------------------------------------------------------
