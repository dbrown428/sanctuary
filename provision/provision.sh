#!/usr/bin/env bash

# Variables
SITE_NAME=$1
SERVER_ROOT="$2/public"
DATABASE_NAME=$3

# Use PHP 7.4
sudo update-alternatives --set php /usr/bin/php7.4
sudo update-alternatives --set php-config /usr/bin/php-config7.4
sudo update-alternatives --set phpize /usr/bin/phpize7.4

# Clear Nginx Sites
rm -f /etc/nginx/sites-enabled/*
rm -f /etc/nginx/sites-available/*

# Update Composer
/usr/local/bin/composer self-update

# Postgres
su postgres -c "dropdb $DATABASE_NAME --if-exists"

if ! su postgres -c "psql $DATABASE_NAME -c '\q' 2>/dev/null"; then
    su postgres -c "createdb -O homestead '$DATABASE_NAME'"
fi

# Setup Nginx
block="server {
    listen 80;
    server_name $SITE_NAME;
    root $SERVER_ROOT;
    index index.html index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}"

echo "$block" > "/etc/nginx/sites-available/$SITE_NAME"
ln -fs "/etc/nginx/sites-available/$SITE_NAME" "/etc/nginx/sites-enabled/$SITE_NAME"

# Restart Services
sudo service nginx restart; 
sudo service php7.4-fpm restart;
