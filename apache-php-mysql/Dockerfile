ARG FROM_PHP_VERSION=8.1
FROM php:${FROM_PHP_VERSION}-apache
RUN docker-php-ext-install pdo pdo_mysql

# enable .htaccess rewrites
RUN a2enmod rewrite

# install the ssl-cert package which will create a "snakeoil" keypair
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y ssl-cert \
 && rm -r /var/lib/apt/lists/*

# enable ssl module and enable the default-ssl site
RUN a2enmod ssl \
 && a2ensite default-ssl
