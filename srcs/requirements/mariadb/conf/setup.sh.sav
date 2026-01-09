#!/bin/bash

# Create dir to sockets if not exist
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Start MariaDB in secure mode to config.
if [ ! -d "/var/lib/mysql/mysql" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Config MariaDB to listen to all interfaces
sed -i 's/blind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Start MariaDB in safe mode to config.
mysqld_safe --datadir=/var/lib/mysql &

# Wait to MariaDB to be ready
until mysqladmin ping --silent; do
	echo "Waiting to MariaDB to start..."
	sleep 2
done

# Config MariaDB if not yet configured
if [ ! -f /var/lib/mysql/.configured ]; then
	echo "Setting MariaDB..."
	mysql -u root << EOF

-- Stablish root pwd
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Create DB
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Create WP user
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

-- Grant privileges to user
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Apply changes
FLUSH PRIVILEGES;
EOF

	touch /var/lib/mysql/.configured
	echo "MariaDB configured successfully"
fi

# Stop temp process
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Start MariaDB
echo "Starting MariaDB..."
exec mysqld --user=mysql --console --bind-address=0.0.0.0

