# Using sid, as currently only sid has php8.2+
FROM debian:sid-slim

# Install pre-requisites, redis and mariadb
RUN apt-get update && \
    apt-get install -y php8.2 php8.2-common php8.2-cli php8.2-gd php8.2-mysql php8.2-mbstring php8.2-bcmath php8.2-xml php8.2-curl php8.2-zip && \
    apt-get install -y apache2 tar unzip git curl sudo nano && \
    rm -rf /var/lib/apt/lists/*

# Add composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configure Apache to server Pterodactyl under port 80 (for HTTPS you MUST use a reverse proxy)
RUN a2dissite 000-default.conf
RUN a2enmod rewrite
COPY apache2.conf /etc/apache2/sites-available/pterodactyl.conf
RUN ln -s /etc/apache2/sites-available/pterodactyl.conf /etc/apache2/sites-enabled/pterodactyl.conf

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]