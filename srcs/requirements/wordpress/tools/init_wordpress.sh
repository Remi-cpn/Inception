#!/bin/bash

# Cree un dossier necessaire a wordpress
mkdir -p /run/php
# Donne les droits au dossiers
chown -R www-data:www-data /run/php
chown -R www-data:www-data /var/www/html

cd /var/www/html

# Regarder si la base existe
if [ ! -f "/var/www/html/wp-config.php" ]; then
	# attendre reponse de mariadb
	until mariadb-admin ping -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
	       sleep 1
	done
	wp core download --allow-root
	wp config create --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost=mariadb --allow-root
	wp core install --url="$DOMAIN_NAME" --title="$SITE_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --allow-root
	wp user create "$WP_USER" "$WP_USER_EMAIL" --role=author --user_pass="$WP_USER_PASSWORD" --allow-root
fi

exec php-fpm8.2 -F
