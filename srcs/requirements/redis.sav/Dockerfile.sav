FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php \
    php-cli \
    php-mysql \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
			&& mv wp-cli.phar /usr/local/bin/wp


COPY conf/redis-setup.sh /usr/local/bin/redis-setup.sh
RUN chmod +x /usr/local/bin/redis-setup.sh

ENTRYPOINT ["/usr/local/bin/redis-setup.sh"]



## Notes:
# Redis runs in its own container, WordPress connects via Docker DNS, and the Redis Object Cache plugin confirms the connection as active.

# Redis runs in its own container, listens on port 6379, and is only accessible through the internal Docker network.# The port is exposed but not published to the host, which fully complies with the subject requirements.
