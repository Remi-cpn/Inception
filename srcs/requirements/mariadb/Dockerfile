FROM debian:bookworm

# apt-get pour silence le warning "apt does not have a stable CLI interface"
# -y pour repondre automatiquement yes
RUN apt-get update && apt-get install -y mariadb-server gettext-base

# Changer l'ecoute du serveur pour qu'il n'ecoute pas que localhost
# EXPOSE 3306
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copie le script dans le bin
COPY ./tools/init_mariadb.sh /usr/local/bin/
COPY ./tools/init.sql.template /usr/local/bin/init.sql.template

# Entrypoint pour qu'il s'execute a chaque docker run
ENTRYPOINT ["bash", "/usr/local/bin/init_mariadb.sh"]
