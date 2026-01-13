FROM debian:bullseye

RUN apt-get update && apt-get install -y \
        nginx \
        openssl \
        ssl-cert \
        && rm -rf /var/lib/apt/lists/*

# Create dir for certs. SSL
RUN mkdir -p /etc/nginx/ssl

# Generate cert. SSL autosign
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/C=ES/ST=Catalonia/L=Barcelona/O=42/OU=42Barcelona/CN=jsayerza.42.fr"

# Create dir for snippets
RUN mkdir -p /etc/nginx/snippets

# Delete default nginx configs
RUN rm -rf /etc/nginx/sites-enabled/* \
    && rm -rf /etc/nginx/sites-available/* \
    && rm -rf /etc/nginx/conf.d/* \
    && rm -f /etc/nginx/nginx.conf

# Copy nginx config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Expose port 443
EXPOSE 443

# Command to start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
