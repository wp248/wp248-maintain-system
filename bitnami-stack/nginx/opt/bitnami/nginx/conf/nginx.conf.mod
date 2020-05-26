
user  daemon daemon;
		worker_processes  auto;

		error_log  "/opt/bitnami/nginx/logs/error.log";

		pid        "/opt/bitnami/nginx/logs/nginx.pid";

		events {
		use                 epoll;
		worker_connections  1024;
		multi_accept        on;
		}


		http {
		include       mime.types;
		default_type  application/octet-stream;

		client_body_temp_path  "/opt/bitnami/nginx/tmp/client_body" 1 2;
		proxy_temp_path "/opt/bitnami/nginx/tmp/proxy" 1 2;
		fastcgi_temp_path "/opt/bitnami/nginx/tmp/fastcgi" 1 2;
		scgi_temp_path "/opt/bitnami/nginx/tmp/scgi" 1 2;
		uwsgi_temp_path "/opt/bitnami/nginx/tmp/uwsgi" 1 2;

		access_log  "/opt/bitnami/nginx/logs/access.log";

		sendfile        on;

		keepalive_timeout  65;
		client_max_body_size 80M;

		gzip on;
		gzip_http_version 1.1;
		gzip_comp_level 2;
		gzip_proxied any;
		gzip_vary on;
		gzip_types text/plain
		text/xml
		text/css
		text/javascript
		application/json
		application/javascript
		application/x-javascript
		application/ecmascript
		application/xml
		application/rss+xml
		application/atom+xml
		application/rdf+xml
		application/xml+rss
		application/xhtml+xml
		application/x-font-ttf
		application/x-font-opentype
		application/vnd.ms-fontobject
		image/svg+xml
		image/x-icon
		application/atom_xml;

		gzip_buffers 16 8k;

		add_header X-Frame-Options SAMEORIGIN;

		ssl_prefer_server_ciphers  on;
		ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
		ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS;

		include "/opt/bitnami/nginx/conf/wp248-bitnami-nginx.conf";
		include "/opt/bitnami/nginx/conf/bitnami/bitnami.conf";

		}
