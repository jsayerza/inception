#!/bin/bash

# Wait for MariaDb to be ready
until mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" &>/dev/null; do
	echo "Waiting for MariaDb to be ready..."
	sleep 3
done

cd /var/www/html

# Download WordPress if it doesn't exist
if [ ! -f wp-config.php ]; then
	echo "Downloading WordPress..."
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

# Start PHP-FPM in foreground
exec php-fpm7.4 -F

