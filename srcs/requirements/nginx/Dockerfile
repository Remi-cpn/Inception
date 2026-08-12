FROM debian:bookworm

# Install les dependences
RUN apt-get update && apt-get install -y nginx openssl

# Donne les droits pour le root
RUN chmod 755 /var/www/html
# Donne les droits pour l'utilisateur www-data
RUN chown -R www-data:www-data /var/www/html

# Setup de la cle ssl
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/certificate.crt -keyout /etc/nginx/ssl/certificate.key -subj "/C=FR/ST=NA/L=Angouleme/O=42/OU=42/CN=rcompain.42.fr/UID=rcompain"

# Copie la comfig
RUN mkdir -p /var/run/nginx
COPY ./conf/nginx.conf /etc/nginx/conf.d

# Set le port 443 pour internet
RUN rm /etc/nginx/sites-enabled/default
EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]

