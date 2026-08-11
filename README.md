# Inception


Commande util pour les dockers:

curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER

docker --version
docker compose version

docker ps -a (le -a montre aussi les arrêtés)
nettoyer avec docker container prune

Stopper les dockers
    docker compose -f srcs/docker-compose.yml down -v
Lancer les dockers
    docker compose -f srcs/docker-compose.yml up -d --build mariadb

Optenir les logs d'un docker
    docker logs mariadb


Mariadb:

SHOW DATABASE // Permet de voir la database

SELECT user, host FROM mysql.user; // Permet de voir les users
