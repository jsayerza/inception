all:	up

up:
	@mkdir -p /home/jsayerza/data/wordpress
	@mkdir -p /home/jsayerza/data/mariadb
	@docker compose -f ./srcs/docker-compose.yml up -d --build

down:
	@docker compose -f ./srcs/docker-compose.yml down

stop:
	@docker compose -f ./srcs/docker-compose.yml stop

start:
	@docker compose -f ./srcs/docker-compose.yml start

status:
	@docker compose -f ./srcs/docker-compose.yml ps

logs:
	@docker compose -f ./srcs/docker-compose.yml logs -f

clean:	down
	@docker system prune -af

fclean:	clean
	@sudo rm -rf /home/jsayerza/data/wordpress/*
	@sudo rm -rf /home/jsayerza/data/mariadb/*
	@docker volume rm srcs_mariadb_data srcs_wordpress_data 2>/dev/null || true

re:	fclean all

.PHONY: all up down stop start status logs clean fclean re


