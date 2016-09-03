## Main site config

server {
	listen 80 default_server;
	listen [::]:80 default_server;

	# SSL configuration
	#
	# listen 443 ssl default_server;
	# listen [::]:443 ssl default_server;
	#
	# Note: You should disable gzip for SSL traffic.
	# See: https://bugs.debian.org/773332
	#
	# Read up on ssl_ciphers to ensure a secure configuration.
	# See: https://bugs.debian.org/765782
	#
	# Self signed certs generated by the ssl-cert package
	# Don't use them in a production server!
	#
	# include snippets/snakeoil.conf;

	server_name demur.red;		## Name of server
	root /var/www/pelican;		## Path to root

	## Disable all methods besides HEAD, GET and POST.
	if ($request_method !~ ^(GET|HEAD|POST)$ ) {
		return 444;
	}

	## Add index.php to the list if you are using PHP
	index index.php index.html index.htm;

	### Deny Stuffs ### {{{
		## Protect specific TXT and config files
		location ~ /(\.|readme.html|readme.md|changelog.txt|changelog.md|contributing.txt|contributing.md|license.txt|license.md|legalnotice|privacy.txt|privacy.md|security.txt|security.md|sample-.*txt)
		{
			deny all;
		}

		## Protect .git files
		location ~ /\.git/ {
			access_log off;
			log_not_found off;
			deny all;
		}

		## Stop logging /theme
		location /theme {
			access_log off;
		}
	### End Deny Stuffs ### }}}

	### Rate Limit ### {{{
	limit_req zone=perip burst=10 nodelay;
	limit_req zone=perserver burst=50;
	### End Rate Limit ### }}}

	### php attempt ### {{{
	## Pass the PHP scripts to FastCGI server listening on /var/run/php5-fpm.sock
	location ~ \.php$ {
		try_files $uri =404;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		include fastcgi_params;
	}
	### End php ### }}}

	### Error Redirects ### {{{
	## Redirect server error pages
	error_page 500 501 502 503 504 /pages/50x;
	error_page 404 /pages/404;
	error_page 403 /pages/403;
	### End Error ### }}}
}
