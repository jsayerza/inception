# 42 Inception - jsayerza
# Developer Documentation - Inception
This document describes how developers can set up, build, and maintain the Inception project.


## Setting Up the Environment from Scratch

### Prerequisites

1. Operating System: Debian 11 (Bullseye) or 12 (Bookworm)
   - Can be installed on a VM (VirtualBox recommended)
   - Minimum 2 GB RAM, 20 GB disk space

2. Install Docker:
# Add Docker's official GPG key
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

3. Configure Docker permissions:
sudo usermod -aG docker $USER

Logout and login again.

4. Install development tools:
sudo apt install -y vim make git tree

### Project Setup

1. Clone the repository:
cd ~
git clone <repository_url> inception
cd inception

2. **Create data directories**:
sudo mkdir -p /home/$USER/data/wordpress
sudo mkdir -p /home/$USER/data/mariadb
sudo chown -R $USER:$USER /home/$USER/data

3. **Configure environment variables**:
cd srcs
vim .env

Create `.env` file with:
# Domain
DOMAIN_NAME=jsayerza.42.fr

# MySQL/MariaDB
MYSQL_ROOT_PASSWORD=your_root_pass
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=your_db_pass

# WordPress Admin (cannot be admin/administrator)
WP_ADMIN_USER=jsayerza
WP_ADMIN_PASSWORD=your_admin_pass
WP_ADMIN_EMAIL=jsayerza@student.42.com

# WordPress Editor
WP_USER=wpeditor
WP_USER_PASSWORD=your_editor_pass
WP_USER_EMAIL=editor@student.42.com

4. Configure domain name:
sudo vim /etc/hosts

Add:
127.0.0.1    jsayerza.42.fr


## Building and Launching

### Using Makefile

The Makefile provides convenient commands:
# Build and start (default)
make

# Build and start in detached mode
make up

# Stop containers
make stop

# Start stopped containers
make start

# Stop and remove containers
make down

# View container status
make status

# View logs (real-time)
make logs

# Clean unused Docker resources
make clean

# Complete cleanup (removes data!)
make fclean

# Rebuild from scratch
make re

### Using Docker Compose Directly
# Build images
docker compose -f srcs/docker-compose.yml build

# Start services
docker compose -f srcs/docker-compose.yml up -d

# Stop services
docker compose -f srcs/docker-compose.yml down

# View logs
docker compose -f srcs/docker-compose.yml logs -f

# Rebuild specific service
docker compose -f srcs/docker-compose.yml up -d --build nginx


## Managing Containers and Volumes

### Container Management

List running containers:
docker ps


List all containers (including stopped):
docker ps -a


Stop a specific container:
docker stop <container_name>

Start a specific container:
docker start <container_name>

Restart a container:
docker restart <container_name>

Remove a container:
docker rm <container_name>

Execute command in container:
docker exec -it <container_name> <command>

Examples:
# Access MariaDB
docker exec -it mariadb mysql -u root -p

# Access WordPress container shell
docker exec -it wordpress bash

# Access NGINX container
docker exec -it nginx bash

### Volume Management

List volumes:
docker volume ls

Inspect volume:
docker volume inspect srcs_wordpress_data
docker volume inspect srcs_mariadb_data

Remove volumes (data will be lost!):
docker volume rm srcs_wordpress_data srcs_mariadb_data

Check volume contents:
ls -la /home/$USER/data/wordpress/
ls -la /home/$USER/data/mariadb/

### Network Management

List networks:
docker network ls

Inspect network:
docker network inspect srcs_inception

Test connectivity between containers:
docker exec wordpress ping mariadb
docker exec nginx ping wordpress


## Project Data Storage and Persistence

### Data Location

All persistent data is stored in:
/home/jsayerza/data/
├── wordpress/     # WordPress files (wp-content, themes, plugins, uploads)
└── mariadb/       # MariaDB database files

### How Persistence Works

1. Docker Volumes are defined in `docker-compose.yml`:
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/jsayerza/data/mariadb

2. Bind mounts link container paths to host paths:
   - Container `/var/lib/mysql` → Host `/home/jsayerza/data/mariadb`
   - Container `/var/www/html` → Host `/home/jsayerza/data/wordpress`

3. Data survives container restarts and rebuilds

### Backup and Restore

Create backup:
sudo tar -czf backup-$(date +%Y%m%d).tar.gz /home/$USER/data/

Restore backup:
make down
sudo rm -rf /home/$USER/data/*
sudo tar -xzf backup-YYYYMMDD.tar.gz -C /
make


## Architecture Overview

### Service Dependencies
nginx (port 443)
  ↓
wordpress (port 9000)
  ↓
mariadb (port 3306)

- NGINX is the entry point, listens on port 443 (HTTPS only)
- WordPress communicates with NGINX via FastCGI on port 9000
- MariaDB provides database backend, accessed by WordPress

### Network Communication

All services communicate via the `inception` bridge network:
- Service discovery by container name (no hardcoded IPs)
- NGINX forwards PHP requests to `wordpress:9000`
- WordPress connects to database at `mariadb:3306`

### Image Build Process

Each service builds from `debian:bullseye`:

1. MariaDB:
   - Install MariaDB server/client
   - Copy setup script
   - Configure for remote access (bind 0.0.0.0)
   - Initialize database and users

2. WordPress:
   - Install PHP-FPM (FastCGI Process Manager) and extensions
   - Download WP-CLI
   - Copy setup script
   - Configure PHP-FPM to listen on port 9000
   - Auto-install WordPress on first run

3. NGINX:
   - Install NGINX and OpenSSL
   - Generate self-signed SSL certificate
   - Copy custom configuration
   - Configure for TLSv1.2/TLSv1.3 only


## Development Workflow

### Making Changes

1. Modify Dockerfile or config:
vim srcs/requirements/nginx/conf/nginx.conf

2. Rebuild specific service:
docker compose -f srcs/docker-compose.yml up -d --build nginx

3. Check logs:
docker logs nginx

### Debugging

Check container logs:
docker logs <container_name>

Access container shell:
docker exec -it <container_name> bash

Check container processes:
docker top <container_name>

Inspect container configuration:
docker inspect <container_name>

Test network connectivity:
docker exec wordpress ping mariadb
docker exec wordpress nc -zv mariadb 3306

### Common Development Tasks

Rebuild everything from scratch:
make fclean
make

View real-time logs from all services:
make logs

Check resource usage:
docker stats

Clean build cache:
docker builder prune


## Security Considerations

### SSL/TLS

- Self-signed certificate for development
- TLSv1.2 and TLSv1.3 only (no older protocols)
- For production: use Let's Encrypt or proper CA certificate

### Credentials

- Never commit `.env` to Git (in `.gitignore`)
- Change default passwords in production
- Use Docker secrets for production deployments

### Network Security

- Only port 443 exposed to host
- All inter-service communication via internal network
- MariaDB not directly accessible from host


## Testing

### Manual Testing Checklist

- [ ] All containers start successfully
- [ ] NGINX responds on https://jsayerza.42.fr
- [ ] WordPress homepage loads
- [ ] Admin panel accessible at /wp-admin
- [ ] Can login with admin credentials
- [ ] Can login with editor credentials
- [ ] Database connection works
- [ ] Data persists after `make down && make`
- [ ] SSL certificate uses TLSv1.2/1.3

### Automated Tests
# Check all containers are running
docker ps | grep -E "mariadb|wordpress|nginx"

# Test NGINX
curl -k https://jsayerza.42.fr

# Test database connection
docker exec mariadb mysql -u wpuser -p wppass123 -e "SHOW DATABASES;"


## Troubleshooting

### Build Failures

Syntax errors in Dockerfile:
- Check for typos (apt-get, not pat-get)
- Verify all RUN commands
- Check line continuations (\)

Network errors during build:
- Check internet connection
- Try: `docker system prune -a`

### Runtime Issues

Container keeps restarting:
docker logs <container_name>

Look for error messages and fix configuration.

"Can't connect to database":
- Check MariaDB is running: `docker ps`
- Verify bind address: `docker logs mariadb | grep "0.0.0.0"`
- Check credentials in `.env`

"NGINX errors":
- Check config syntax: `docker exec nginx nginx -t`
- Verify SSL certificate exists
- Check logs for specific errors

## Project Structure Reference
inception/
├── Makefile                          # Build automation and commands
├── README.md                         # Project overview and instructions
├── USER_DOC.md                       # User/admin documentation
├── DEV_DOC.md                        # Developer documentation (this file)
├── .gitignore                        # Files to exclude from Git
└── srcs/
    ├── .env                          # Environment variables (not in Git)
    ├── docker-compose.yml            # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile            # MariaDB image definition
        │   └── conf/
        │       └── setup.sh          # Database initialization script
        ├── nginx/
        │   ├── Dockerfile            # NGINX image definition
        │   └── conf/
        │       └── nginx.conf        # NGINX configuration
        └── wordpress/
            ├── Dockerfile            # WordPress image definition
            └── conf/
                └── setup.sh          # WordPress setup script


## Contributing

1. Create a feature branch
2. Make changes
3. Test thoroughly
4. Commit with clear messages
5. Push and create pull request

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

