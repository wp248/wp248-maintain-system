# ===========================================================================
# Note:
#      Search and replace domain: example.com  with you own domain
# ===========================================================================

# Force HTTP 2 HTTPS Redirection
# CASE 1: wildcard ssl Force HTTP 2 HTTPS Redirection on any domain that not have an app
server {
	listen       80;
	server_name  WP248_NGX_DOMAINS;
	return 301 https://WP248_PRIMARY_DOMAIN$request_uri;
	#include "/opt/bitnami/nginx/conf/bitnami/phpfastcgi.conf";
	include "/opt/bitnami/nginx/conf/bitnami/bitnami-apps-prefix.conf";
}

# CASE 2: Any other names (includes: 127.0.0.1, localhost, service domain name) no redirect
#         For PhpMyAdmin and others
server {
	listen       80 default_server;
	server_name  localhost;

	#include "/opt/bitnami/nginx/conf/bitnami/phpfastcgi.conf";
	include "/opt/bitnami/nginx/conf/bitnami/bitnami-apps-prefix.conf";
	# Do Not add rocket-nginx to default http - it will cause problem with port forward on localhost
	#include "/opt/bitnami/nginx/conf/rocket-nginx.conf";
}

# CASE 3: SSL for any sub domains in the wildcard ssl  Redirection to https://example.com/

server {
	listen       443 ssl;
	server_name  WP248_NGX_WITHOUT_PRIMARY_DOMAIN;

	return 301 https://WP248_PRIMARY_DOMAIN$request_uri;

	ssl_certificate      server.crt;
	ssl_certificate_key  server.key;
	#
	ssl_session_cache    shared:SSL:1m;
	ssl_session_timeout  5m;
	#
	ssl_ciphers  HIGH:!aNULL:!MD5;
	ssl_prefer_server_ciphers  on;
	#
	#include "/opt/bitnami/nginx/conf/bitnami/phpfastcgi.conf";
	include "/opt/bitnami/nginx/conf/bitnami/bitnami-apps-prefix.conf";
	#include "/opt/bitnami/nginx/conf/rocket-nginx.conf";
	# Support Imagify and webp
	#include "/opt/bitnami/nginx/conf/imagify.conf";
}

# CASE 4: Default Server SSL no redirection
server {
	listen       443 ssl default_server;
	server_name  localhost;

	#fastcgi_hide_header Set-Cookie;
	ssl_certificate      server.crt;
	ssl_certificate_key  server.key;
	#
	ssl_session_cache    shared:SSL:1m;
	ssl_session_timeout  5m;
	#
	ssl_ciphers  HIGH:!aNULL:!MD5;
	ssl_prefer_server_ciphers  on;
	#
	#include "/opt/bitnami/nginx/conf/bitnami/phpfastcgi.conf";
	include "/opt/bitnami/nginx/conf/bitnami/bitnami-apps-prefix.conf";
	# Add rocket-nginx
	#include "/opt/bitnami/nginx/conf/rocket-nginx.conf";
	# Support Imagify and webp
	#include "/opt/bitnami/nginx/conf/imagify.conf";
}

include "/opt/bitnami/nginx/conf/bitnami/bitnami-apps-vhosts.conf";

# Status
server {
	listen 80;
	server_name local-stackdriver-agent.stackdriver.com;
	location /nginx_status {
	  stub_status on;
	  access_log   off;
	  allow 127.0.0.1;
	  deny all;
	}

	location / {
	  root /dev/null;
	}
}
