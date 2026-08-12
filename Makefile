LOGIN	= rcompain
COMPOSE = docker compose -f ./srcs/docker-compose.yml
R 	= \033[0m
CYAN	= \033[36m

all: up

up:
	@mkdir -p /home/$(LOGIN)/data
	@mkdir -p /home/$(LOGIN)/data/mariadb
	@mkdir -p /home/$(LOGIN)/data/wordpress
	@$(COMPOSE) up -d --build

down:
	@$(COMPOSE) down
	@printf "$(CYAN)Dockers downed$(R)\n"

clean:
	@$(COMPOSE) down -v
	@printf "$(CYAN)Volume cleaned$(R)\n"

fclean: clean
	@sudo rm -rf /home/$(LOGIN)/data
	@printf "$(CYAN)/home/$(LOGIN)/data deleted $(R)\n"

re: clean all

logs:
	@$(COMPOSE) logs

ps:
	@$(COMPOSE) ps


.PHONY: all up down clean fclean re logs ps
