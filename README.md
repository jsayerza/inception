# 42 Inception jsayerza
## Description
Inception is a system administration project that focuses on conteinerization using Docker. 
The goal is to set up a small infrastructure composed of different services, each running in its own dedicated container, orchestrated with Docker Compose. 

This project implementes:
- NGINX web server with TLSv1.2/TLSv1.3 support
- WordPress CMS with php-fpm 
- MariaDB database
- Docker volumes for persistent data storage
- A custom docker network for inter-container communication

All Docker images are built from scratch using custom Dockerfiles based on Debian Bullseye, without using pre-built images from Dockerhub.

## Instructions

### Prerequisites
- Debian-based Linux system (or VM)
- Docker Engine installed
- Docker Compose plugin installed
- At least 10 GB free disk space
- Root/sudo access

### Compilation & Installation

1. Clone the repository:
    git clone
    cd inception

2. Configure environment variables:
    cd srcs
    cp .env.example .env
    # edit .env with your credentials

3. Build and start the project:
    make

### Execution

- Start services: 'make' or 'make up'
- Stop services: 'make stop'
- Restart services: 'make re'
- View logs: 'make logs'
- Check status: 'make status'
- Clean up: 'make fclean' (removes all data and volumes)

### Access

Once the containers are running, access the website at:
- Website: https://jsayerza.42.fr
- Admin panle: https://jsayerza.42.fr/wp-admin

Note: You'll see a security warning because the SSL certificate is self-signed.


## Resources

### Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.org/documentation/)

### Tutorials & Articles
- [Docker Networking Guide](https://docs.docker.com/network/)
- [Docker Volumes Guide](https://docs.docker.com/storage/volumes/)
- [SSL/TLS Configuration Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS)


## Project dessign choices

### Virtual Machines vs Docker

Conceptual differences between these virtualization technologies, both of which are used in this project setup.

Virtual Machines (VMs):
- Full OS virtualization with a hypervisor (e.g., VirtualBox, VMware)
- Each VM runs a complete operating system with its own kernel
- Higher resource overhead (RAM, CPU, disk) - each VM needs GBs
- Complete hardware-level isolation
- Slower startup times (minutes to boot an OS)
- Use case: Running different operating systems, complete isolation

Docker Containers:
- OS-level virtualization that shares the host's kernel
- Containers are isolated processes, not full operating systems
- Lightweight - MBs instead of GBs
- Fast startup times (seconds)
- Better resource efficiency for running multiple services
- Use case: Microservices, application deployment, dev environments

In this project:
- The VM (Debian on VirtualBox) provides the isolated development environment required by the subject
- Docker containers run the individual services (NGINX, WordPress, MariaDB) within that VM
- This combination gives us both isolation (VM) and efficiency (containers)

Why both?
- The subject requires a VM for the project environment
- Docker containers are used to implement the microservices architecture
- Each service runs in its own container for modularity and ease of management
- This reflects real-world infrastructure where Docker often runs on VMs in cloud environments (AWS EC2, Azure VMs, etc.)

### Secrets vs Environment variables

Env vars:
- Simple key-value pairs
- Easily accessible in container
- Stored in '.env' file (expluded from Git)
- Good for non-critical configuration

Docker secrets:
- Encrypted during transit and at rest
- More secure for sensitive data
- Only available in Swarm mode
- Better for production environments

Choice: Env vars were used as the project runs in standard Docker Compose (not Swarm). The .env` file is gitignored to prevent credential exposure.

### Docker network vs Host network

Docker network:
- Isolated network for containers
- Service discovery by container name
- Better security through isolation
- Port mapping control

Host network:
- Container uses host's network stack
- No network isolation
- Better performance (no NAT overhead)
- Security concerns

Choice: Custom bridge network ('inception') for service isolation, security, and Docker's built-in DNS for service discovery.

### Docker volumes vs Bind mounts

Docker volumes:
- Managed by Docker
- Better perfomance on non-Linux hosts
- Can be managed with Docker CLI
- Backup/migration support

Bind mounts:
- Direct host filesystem mapping
- Full control over mount location
- Easier to access from host
- Dependent on host directory structure

Choice: Bind mounts to '/home/jsayerza/data' as required by the subject, providing easy access to persistent data and meeting project specifications.


## Project Structure
inception/
├── Makefile                   # Build automation
├── README.md                  # This file
├── USER_DOC.md                # User documentation
├── DEV_DOC.md                 # Developer documentation
└── srcs/
    ├── .env                   # Environment variables (gitignored)
    ├── docker-compose.yml     # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   └── conf/
        │       └── setup.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        └── wordpress/
            ├── Dockerfile
            └── conf/
                └── setup.sh


jsayerza - 42 Barcelona
