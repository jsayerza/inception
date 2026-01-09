FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

# Copy config and script
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY conf/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Create dir for FTP
RUN mkdir -p /var/run/vsftpd/empty

# Expose FTP ports
EXPOSE 21 21000-21010

# Execute setup script
ENTRYPOINT ["/usr/local/bin/setup.sh"]


## Notes:
## vsftpd (Very Secure FTP Daemon)

