#!/bin/bash
set -e
# Cree un dossier necessaire a mairadb
mkdir -p /run/mysqld
# Donne les droits a ce dossier
chown -R mysql:mysql /run/mysqld

if [ ! -d /var/lib/mysql/wordpress ]; then
	envsubst < /usr/local/bin/init.sql.template > /tmp/init.sql
	exec mariadbd --init-file=/tmp/init.sql
fi

exec mariadbd
