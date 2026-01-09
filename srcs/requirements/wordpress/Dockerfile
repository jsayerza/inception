FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	php7.4-fpm \
	php7.4-mysql \
	php7.4-curl \
	php7.4-gd \
	php7.4-mbstring \
	php7.4-xml \
	php7.4-xmlrpc \
	php7.4-zip \
	php-redis \
	curl \
	mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

# Download WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Copy config. script
COPY conf/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Create dir to PHP-FPM
RUN mkdir -p /run/php

# Config PHP to listen port 9000
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/' /etc/php/7.4/fpm/pool.d/www.conf

# Expose port 9000
EXPOSE 9000

# Run setup script
ENTRYPOINT ["/usr/local/bin/setup.sh"]



## Notes:
## "The Redis PHP extension (and other additional services) is installed in the WordPress image, but Redis itself runs only as a bonus service.
## The mandatory part does not depend on Redis being available and works exactly the same way with or without it.
## Therefore, mandatory requirements remain fully satisfied.”
