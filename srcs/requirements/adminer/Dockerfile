FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Descargar Adminer
RUN mkdir -p /var/www/html && \
    wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /var/www/html/index.php && \
    chown -R www-data:www-data /var/www/html

# Configurar PHP-FPM
RUN mkdir -p /run/php && \
    sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/' /etc/php/7.4/fpm/pool.d/www.conf

# Exponer puerto
EXPOSE 9000

# Iniciar PHP-FPM
CMD ["php-fpm7.4", "-F"]



## Notes:
# - Adminer is **a single PHP file**. # By naming it `index.php`, it will be the default file served by the web server,
# access it with `https://jsayerza.42.fr/adminer` and it loads automatically
#
# - PHP-FPM runs as the `www-data` user for security reasons.
# If the files belong to `root`, PHP-FPM cannot read/execute them.
# By changing the owner to `www-data`, PHP can access them without problems.
# 
# - By default, PHP-FPM uses a "Unix socket" (internal door (only accessible from inside)):
# listen = /run/php/php7.4-fpm.sock
# But in Docker, we need it to listen on a "TCP port" (exterior door (accessible from other containers)) so that other containers (NGINX) can connect:
# listen = 9000
# `sed` = command-line text editor, `-i` = edits the file directly (in-place), `'s/ORIGINAL/REPLACEMENT/'` = searches for ORIGINAL and replaces it with REPLACEMENT, `/run/php/php7.4-fpm.sock` = Unix socket (default configuration) - the `\` escape the `/`, `9000` = TCP port, `/etc/php/7.4/fpm/pool.d/www.conf` = PHP-FPM configuration file
#
# -F keeps PHP-FPM in the foreground.
# By default, PHP-FPM runs as a daemon (in the background). In Docker, the main process must run in the foreground. If it runs in the background, Docker thinks the container has finished and stops it.
#  Without -F: You open an application, it minimizes, and you close the window → app closed
#  With -F: You open an application and it remains visible → it continues running

