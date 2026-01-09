FROM debian:bullseye

RUN sed -i 's|deb.debian.org|ftp.es.debian.org|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Copy config. scripts
COPY conf/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Expose MariaDB port
EXPOSE 3306

# Execute setup script
ENTRYPOINT ["/usr/local/bin/setup.sh"]

