#!/bin/bash

# Create socket directory
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Initialize if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Listen on all interfaces
sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Start MariaDB temporarily to run setup
mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
MYSQL_PID=$!

# Wait for MariaDB to start
for i in {30..0}; do
    if mysql --protocol=socket -uroot -hlocalhost --socket=/run/mysqld/mysqld.sock -e "SELECT 1" &> /dev/null; then
        break
    fi
    echo "Waiting for MariaDB to start..."
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "MariaDB failed to start" >&2
    exit 1
fi

# Create database and user
echo "Creating database and user..."
mysql --protocol=socket -uroot -hlocalhost --socket=/run/mysqld/mysqld.sock <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Stop temporary MariaDB
kill ${MYSQL_PID}
wait ${MYSQL_PID}

# Start MariaDB normally
echo "Starting MariaDB normally..."
exec mysqld --user=mysql --console

