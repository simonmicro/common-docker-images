# Using sid, as currently only sid has php8.1+
FROM debian:sid-slim

# Install pre-requisites, redis and mariadb
RUN apt-get update && \
    apt-get install -y php8.1 php8.1-common php8.1-cli php8.1-gd php8.1-mysql php8.1-mbstring php8.1-bcmath php8.1-xml php8.1-curl php8.1-zip && \
    apt-get install -y apache2 tar unzip git curl nano && \
    rm -rf /var/lib/apt/lists/*

# Add composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configure Apache to server Pterodactyl under port 80 (for HTTPS you MUST use a reverse proxy)
RUN a2dissite 000-default.conf
RUN a2enmod rewrite
COPY apache2.conf /etc/apache2/sites-available/pterodactyl.conf
RUN ln -s /etc/apache2/sites-available/pterodactyl.conf /etc/apache2/sites-enabled/pterodactyl.conf

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]