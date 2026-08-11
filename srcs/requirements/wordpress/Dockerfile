FROM debian:bookworm

# Install les dependences
RUN apt-get update && apt-get install -y php-fpm php-mysql curl mariadb-client

RUN curl -o /usr/local/bin/wp  https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x /usr/local/bin/wp

# Copie le script dans le bin
COPY ./tools/init_wordpress.sh /usr/local/bin

# Passer l'ecoute socket en TCP pour nginx
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Entrypoint pour qu'il s'execute a chaque docker run
ENTRYPOINT ["bash", "/usr/local/bin/init_wordpress.sh"]
