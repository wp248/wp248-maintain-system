index index.php index.html index.htm;

		if ($request_uri !~ "^/phpmyadmin.*$")
		{
		set $test  A;
		}
		if ($request_uri !~ "^/bitnami.*$")
		{
		set $test  "${test}B";
		}
		if (!-e $request_filename)
		{
		set $test  "${test}C";
		}
		if ($test = ABC) {
		rewrite ^/(.+)$ /index.php?q=$1 last;
		}

		# Deny access to any files with a .php extension in the uploads directory
		location ~* /(?:uploads|files)/.*\.php$ {
		deny all;
		}

		# Disable logging for not found files and access log for the favicon and robots
		location = /favicon.ico {
		log_not_found off;
		access_log off;
		}
		location = /robots.txt {
		allow all;
		log_not_found off;
		access_log off;
		}



		include "/opt/bitnami/apps/bitnami/banner/conf/banner-substitutions.conf";
		include "/opt/bitnami/apps/bitnami/banner/conf/banner.conf";

		# Deny all attempts to access hidden files such as .htaccess or .htpasswd.
		location ~ /\. {
		deny all;
		}

		location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_read_timeout 300;
		fastcgi_pass unix:/opt/bitnami/php/var/run/www.sock;
		fastcgi_index index.php;
		fastcgi_param  SCRIPT_FILENAME $request_filename;
		include fastcgi_params;
		}

		include "/opt/bitnami/apps/wordpress/conf/wp248-cors.conf";
