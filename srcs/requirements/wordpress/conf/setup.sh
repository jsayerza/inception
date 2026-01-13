#!/bin/bash

set -e
WP_PATH="/var/www/html"

# Wait for MariaDb to be ready
until mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" &>/dev/null; do
	echo "[WP] Waiting for MariaDb to be ready..."
	sleep 3
done

cd $WP_PATH

# Download WordPress if it doesn't exist
if [ ! -f wp-config.php ]; then
	echo "Downloading WordPress..."
	# Download latest stable WordPress version
	wp core download --allow-root

	echo "Setting WordPress..."
	wp config create \
		--dbname=${MYSQL_DATABASE} \
		--dbuser=${MYSQL_USER} \
		--dbpass=${MYSQL_PASSWORD} \
		--dbhost=mariadb \
		--allow-root

	echo "Installing WordPress..."
	wp core install \
		--url=${DOMAIN_NAME} \
		--title="Inception WordPress" \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--allow-root

	echo "Create second user..."
	wp user create \
		${WP_USER} \
		${WP_USER_EMAIL} \
		--role=editor \
		--user_pass=${WP_USER_PASSWORD} \
		--allow-root

	echo "WordPress configured successfully."
fi



# Redis bonus configuration
echo "[WP] Waiting for Redis..."
TIMEOUT=30
while ! nc -z redis 6379 >/dev/null 2>&1; do
    sleep 2
    TIMEOUT=$((TIMEOUT-2))
    if [ $TIMEOUT -le 0 ]; then
        echo "[WP] Redis not available -> fallback to MariaDB"
        rm -f wp-content/object-cache.php
        exec php-fpm7.4 -F
    fi
done

echo "[WP] Redis detected -> configuring"
wp config set WP_REDIS_HOST redis --allow-root --path="$WP_PATH"
wp config set WP_REDIS_PORT 6379 --raw --allow-root --path="$WP_PATH"
wp config set WP_CACHE true --raw --allow-root --path="$WP_PATH"

wp plugin install redis-cache \
    --activate \
    --allow-root --path="$WP_PATH" || true

wp redis enable --allow-root --path="$WP_PATH" || true

echo "[WP] Redis enabled successfully"



# Start PHP-FPM in foreground
exec php-fpm7.4 -F
echo "PHP-FPM started successfully."

echo "Wordpress started successfully."



## Notes:
# Redis is a bonus service.
# WordPress works independently and only uses Redis when it is available.
# If Redis is down, WordPress automatically falls back to database queries,
# the object-cache drop-in is not used and WordPress falls back to MySQL seamlessly.
# Redis is enabled optimistically.
#  If it’s available, WordPress uses it.
#  If it’s not, the object-cache drop-in is removed and WordPress falls back to MariaDB without interruption.
#
# - Wait MariaDB
# - Install WP
# - Wait Redis TCP 6379
# - If Redis does not appear in 30s → continue without Redis
# - If Redis appears → configure + enable
# - Zero fatal errors
