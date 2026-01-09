#!/bin/sh

set -e

WP_PATH="/var/www/html"
TIMEOUT=60

echo "[Redis setup] Waiting for wp-config.php..."
while [ $TIMEOUT -gt 0 ]; do
	if [ -f "$WP_PATH/wp-config.php" ]; then
		echo "[redis] wp-config.php found"
		break
	fi
	sleep 3
	TIMEOUT=$((TIMEOUT - 3))
done
if [ ! -f "$WP_PATH/wp-config.php" ]; then
	echo "[redis] Timeout waiting for wp-config.php"
	exit 1
fi

echo "[Redis setup] Waiting for database connection..."
TIMEOUT=60
while [ $TIMEOUT -gt 0 ]; do
	if wp db check --allow-root --path="$WP_PATH" > /dev/null 2>&1; then
		echo "[redis] Database connection OK"
		break
	fi
	sleep 3
	TIMEOUT=$((TIMEOUT - 3))
done
if ! wp db check --allow-root --path="$WP_PATH" > /dev/null 2>&1; then
	echo "[redis] Timeout waiting for database"
	exit 1
fi

echo "[Redis setup] Configuring wp-config.php..."
wp config set WP_REDIS_HOST redis --allow-root --path="$WP_PATH" || true
wp config set WP_REDIS_PORT 6379 --raw --allow-root --path="$WP_PATH" || true
wp config set WP_CACHE true --raw --allow-root --path="$WP_PATH" || true

echo "[Redis setup] Installing Redis Object Cache plugin..."
wp plugin install redis-cache \
	--activate \
	--allow-root \
	--path="$WP_PATH" || true

echo "[Redis setup] Enabling Redis cache..."
wp redis enable --allow-root --path="$WP_PATH" || true

echo "[Redis setup] Redis plugin configured successfully and enabled"
#echo "[Redis setup] Redis plugin installed successfully but NOT forced"



## Notes:
# I use set -e to avoid partial setups, and || true only where failure is acceptable to ensure idempotency.
# WP-CLI blocks root execution by default. In Docker containers, initialization scripts run as root, so --allow-root is required and expected.

# set -e		--> Si qualsevol comanda retorna un codi != 0, surt immediatament del script.
# wp db check	--> comprova: Connexio a MariaDB, Credencials correctes, DB existent
# > /dev/null	--> descarta stdout
# 2>&1			--> descarta stderr
#				--> No mostra res per pantalla, Nomes importa el codi de sortida
# wp config set WP_REDIS_HOST redis --allow-root --path="$WP_PATH"	--> Afegeix (o actualitza) al wp-config.php: define('WP_REDIS_HOST', 'redis');
# || true	--> evita que l'script peti (x set -e) si falla la 1a condicio, i fa q l'script continui

