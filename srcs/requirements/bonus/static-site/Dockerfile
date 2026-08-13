FROM debian:bookworm

RUN apt-get update && apt-get install -y apache2

COPY ./conf/ports.conf /etc/apache2/ports.conf
COPY ./conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf

COPY ./html /var/www/html

EXPOSE 81

ENTRYPOINT ["apachectl", "-D", "FOREGROUND"]
