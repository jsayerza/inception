# 42 Inception - jsayerza
# User documentation
How to use the Inception project from an end-user or administrator perspective.

## Services provided in the Inception stack
1. WordPress website - A full functional content management system
2. NGINX web server - Secure HTTPS access with TLS encryption
3. MariaDB database - Persistent data storage for WordPress

## Starting the project

### Quick start

To start all services:
cd inception
make

This command will:
- Create necessary data directories
- Buils all Docker images
- Start all containers in the correct order
- Set up the network and volumes


### First time setup

When the project is started for the first time:
1. Wait 1-2 minutes for all serices to initialize
2. WordPress will be automatically installed and configured
3. 2 users will be created: admin y editor


## Stopping the project

### Temporay stop

To stop services without removing data:
make stop

To restart stopped services:
make start

To stop remove containers:
make down

Data will be preserved in '/home/jsayerza/data/'


## Accessing the website

### Main website

Open a browser and go to:
https://jsayerza.42.fr

**Security warning**: You'll see a certificate warning because a self-signed SSL certificate is used. Click "Advanced" and proceed to the site.

### Administration panel

To manage the WordPress site:
https://jsayerza.42.fr/wp-admin


## Managin credentials

### Location of credentials

All credentials a stored in:
/home/jsayerza/inception/srcs/.env

### Default credentials

WordPress admin:
- Username: jsayerza
- Password: admin123
- email:    jsayerza@student.42barcelona.com

WordPress editor:
- Username: wpeditor
- Password: editor123
- email:    editor@student.42barcelona.com

### Changing credentials

1. Edit the .env file:
cd ~/inception/srcs
vim .env

2. Modify the desired passwords

3. Completely rebuild the project:
cd ~/inception
make fclean
make

**Warning: 'make fclean' will delete all existing data!**


## Checking service status

### Quick status check
make status

This shows all running containers and their status

### Detailed status
docker ps

All three containers should show status 'Up':
- mariadb
- wordpress
- nginx

### Viewing logs

To see rel/time logs from all services>
make logs

Press 'ctrl+c' to exit.

To view logs from a specific service:
docker logs mariadb
docker logs wordpress
docker logs nginx


## Verifying services are running correctly

### 1. Chck container health
docker ps

Expected output: all containers with "Up" status, no "Restarting".

### 2. Test database connection
docker exec -it mariadb mysql -u wpuser -p

Enter password: wppass123

If you can connect, the database is working.

### 3. Test WordPress

Visit: https://jsayerza.42.fr

You should see the WordPress homepage.

### 4. Test NGINX
docker logs nginx

Should show no error messages.

#### 5. Check persistent data
ls -la /home/jsayerza/data/wordpress/
ls -la /home/jsayerza/data/mariadb/

Both directories should contain files


## Common issues

### "Cannot connect to Docker daemon"

Solution: Make sure Docker is running:
sudo systemctl start docker

### "Permission denied"

Solution: Make sure your user is in the docker group:
sudo usermod -aG docker $USER

Then logout and login again.

### "Port 443 already in use"

Solution: Another service is using port 443. Stop it or change the port in `docker-compose.yml`.

### Website shows "Error establishing database connection"

Solution: 
1. Wait 30 seconds for MariaDB to fully start
2. Check MariaDB logs: `docker logs mariadb`
3. Restart: `make down && make`

### SSL Certificate Warning

This is expected behavior. The certificate is self-signed for development. Click "Advanced" and proceed.


## Data Backup

### Manual backup
sudo tar -czf inception-backup-$(date +%Y%m%d).tar.gz /home/jsayerza/data/

### Restore from backup
make down
sudo rm -rf /home/jsayerza/data/*
sudo tar -xzf inception-backup-YYYYMMDD.tar.gz -C /
make


## Maintenance

### Update WordPress
1. Access: https://jsayerza.42.fr/wp-admin
2. Go to Dashboard → Updates
3. Click "Update Now"

### Clean Unused Docker Resources
make clean

This removes unused images and containers.

### Complete Reset

**Warning**: This deletes ALL data!
make fclean
make


## Support

For technical issues:
1. Check logs: `make logs`
2. Verify status: `make status`
3. Review this documentation
4. Contact: jsayerza@student.42barcelona.com


