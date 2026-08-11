#!/bin/bash

# Cree un dossier necessaire a mairadb
mkdir -p /run/mysqld
# Donne les droits a ce dossier
chown -R mysql:mysql /run/mysqld

# Regarder si la base existe
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
	mysqld &
	# attente lancement de mysqld
	until mysqladmin ping --silent; do
    		sleep 1
	done
	# <<- Le - permet d'ignorer les tabulations
	mysql <<- EOF
	CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
	CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
	ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
	GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
	FLUSH PRIVILEGES;
	EOF
	# Arret du server tmp avec les droits
	mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
fi


exec mysqld
