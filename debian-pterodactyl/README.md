# Notes
Use `docker run` with respective volume mounts to seed this install.
_Keep in mind, that you'll need to start ANOTHER container with `mariadb` and `redis`, as this image is only intended to run the panel!_

## HowTo seed
To make sure this image works and is configured correctly, I've tested it with this:

Build this image locally:
```bash
docker build -t local_debian-pterodactyl .
```

### Preparing the panel
Start your interactive Pterodactyl-setup:
```bash
docker run -it --rm -v $(pwd)/pterodactyl/:/var/www/pterodactyl local_debian-pterodactyl bash
# Now follow https://pterodactyl.io/panel/1.0/getting_started.html - I've executed this:
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/
```

### Intermission: MariaDB
Now you'll need to start the database and seed it (create user and first database). For that , just use this docker-compose file (taken from https://github.com/docker-library/docs/blob/master/mariadb/README.md):
```yaml
version: '3.1'

services:
  db:
    image: mariadb
    restart: always
    environment:
      MARIADB_ROOT_PASSWORD: passw0rd # Change this!
      MARIADB_DATABASE: pterodactyl
      MARIADB_USER: pterodactyl
      MARIADB_PASSWORD: passw0rd # Change this!
    volumes:
      - ./mariadb:/var/lib/mysql
    ports:
      - 3306:3306
```
You can skip the "Database Configuration" step in the pterodactyl setup, as the database `pterodactyl` and the respective user `pterodactyl` are already created.

### Intermission: Redis
Later you may want to use Redis - so here is a quick command for that (no password set):
```bash
docker run -it --rm -v $(pwd)/redis:/data -p 6379:6379 redis redis-server --save 60 1 --loglevel warning
```

### Back to the panel

Now back to the interactive panel setup:
```bash
cp .env.example .env
composer install --no-dev --optimize-autoloader

# Only run the command below if you are installing this Panel for
# the first time and do not have any Pterodactyl Panel data in the database.
php artisan key:generate --force

php artisan p:environment:setup
```
**As you are running multiple docker containers, `localhost` of e.g. the panel != `localhost` of redis. You'll need to use e.g. your PCs interface IPv4 addresses to allow cross-container communication - keep in mind to revert these settings inside the `.env` later if you run in Kubernetes!**
```bash
php artisan p:environment:database

# To use PHP's internal mail sending (not recommended), select "mail". To use a
# custom SMTP server, select "smtp".
php artisan p:environment:mail

php artisan migrate --seed --force

php artisan p:user:make
```

No need to configure Apache2 - a viable configuration is already baked into the image.
Now start the panel:
```bash
docker run -it --rm -v $(pwd)/pterodactyl/:/var/www/pterodactyl -p 80:80 local_debian-pterodactyl
```
You'll may need to [disable Recapture](https://pterodox.com/guides/disabling-reCAPTCHA.html#disabling-via-env) for local testing.

### Panel jobs and queue
You now have a working panel, but you'll need to start the queue worker and the job scheduler:
```bash
docker run -it --rm -v $(pwd)/pterodactyl/:/var/www/pterodactyl local_debian-pterodactyl sudo -u www-data bash -c "sleep 10; while true; do php /var/www/pterodactyl/artisan schedule:run; sleep 60; done" # Job scheduler
docker run -it --rm -v $(pwd)/pterodactyl/:/var/www/pterodactyl local_debian-pterodactyl sudo -u www-data bash -c "sleep 10; /usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3" # Queue worker
```

# Kubernetes
Well, I won't help you on that one :)

Overall you have to run this as follows:
* Overall Kubernetes idea
  * One pod with all panel services (disable process isolation `shareProcessNamespace`)
    * One container with the panel (no command overwrite!)
    * One container with the job-scheduler of the panel (use the `container.X.command` field with the command from above)
    * One container with the worker of the panel (use the `container.X.command` field with the command from above)
  * One container with the mariadb instance
  * One container with the redis instance
* Make sure to properly mount all needed volumes to prevent data loss!
* For HTTPS you'll need to use a reverse proxy (e.g. nginx) and use a service pointing to the pod with the panel