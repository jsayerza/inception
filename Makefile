DC			= docker compose
DC_BASE		= ./srcs/docker-compose.yml
DC_BONUS	= ./srcs/docker-compose.override.yml

DATA_DIR	= /home/jsayerza/data
WP_DATA		= $(DATA_DIR)/wordpress
DB_DATA		= $(DATA_DIR)/mariadb


all:	up

up:
	@mkdir -p $(WP_DATA)
	@mkdir -p $(DB_DATA)
	@$(DC) -f $(DC_BASE) up -d --build

bonus:
	@mkdir -p $(WP_DATA)
	@mkdir -p $(DB_DATA)
	@$(DC) -f $(DC_BASE) -f $(DC_BONUS) up -d --build

down:
	@$(DC) -f $(DC_BASE) down

down_bonus:
	@echo "Downing all dockers..."
	@$(DC) -f $(DC_BASE) -f $(DC_BONUS) down --remove-orphans

stop:
	@$(DC) -f $(DC_BASE) stop

start:
	@$(DC) -f $(DC_BASE) start

status:
	@$(DC) -f $(DC_BASE) ps

logs:
	@$(DC) -f $(DC_BASE) logs -f

clean:	down_bonus
	## it removes unused images
	@docker system prune -af

fclean:	clean
	@sudo rm -rf /home/jsayerza/data/wordpress/*
	@sudo rm -rf /home/jsayerza/data/mariadb/*
	@docker volume rm srcs_mariadb_data srcs_wordpress_data 2>/dev/null || true

re:	fclean all

ftp-test:
	@echo "Testing FTP connection..."
	@ftp localhost 21

.PHONY: all up bonus down down_bonus stop start status logs clean fclean re ftp-test



## Notes:
# The mandatory part runs independently using docker-compose.yml.
# Bonus services are added only through docker-compose.override.yml and are launched explicitly via make bonus.
# This guarantees that the mandatory part can be evaluated alone, as required by the subject.

# Acció              | Fitxer correcte 
# ------------------ | ----------------
# `chmod +x`         | `Dockerfile`    
# Copiar scripts     | `Dockerfile`    
# Iniciar serveis    | `setup.sh`      
# Orquestrar serveis | `docker-compose`
# Build / lifecycle  | `Makefile`      

# chmod, apt-get, COPY → Dockerfile
# wait, wp, mysql, redis → setup.sh
