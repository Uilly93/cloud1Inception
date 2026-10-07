#!/bin/bash
set -e

echo "Waiting for MariaDB..."
until nc -z mariadb 3306; do
    echo "MariaDB is not ready yet..."
    sleep 2
done

echo "MariaDB is ready!"

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download \
        --path=/var/www/html \
        --allow-root \
        --force
fi

if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
    echo "Installing WordPress..."

    rm -f /var/www/html/wp-config.php

    wp core config \
        --path=/var/www/html \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$WORDPRESS_DB_PASSWORD \
        --dbhost=$WORDPRESS_DB_HOST \
        --allow-root

    wp core install \
        --path=/var/www/html \
        --url=$WORDPRESS_SITE_URL \
        --title="$TITLE" \
        --admin_user=$WORDPRESS_ADMIN_USER \
        --admin_password=$WORDPRESS_ADMIN_PASSWORD \
        --admin_email=$WORDPRESS_ADMIN_EMAIL \
        --allow-root

    wp user create \
        "$WORDPRESS_USER1" \
        "$WORDPRESS_USER1_EMAIL" \
        --role=author \
        --user_pass="$WORDPRESS_USER1_PASSWORD" \
        --path=/var/www/html \
        --allow-root

    wp option update home "$WORDPRESS_SITE_URL" \
        --path=/var/www/html \
        --allow-root

    wp option update siteurl "$WORDPRESS_SITE_URL" \
        --path=/var/www/html \
        --allow-root

    wp search-replace \
        "https://jealefev.42.fr" \
        "$WORDPRESS_SITE_URL" \
        --all-tables \
        --allow-root

    wp cache flush --allow-root
fi

if wp theme is-installed online-video-games --path=/var/www/html --allow-root; then
    wp theme activate online-video-games \
        --path=/var/www/html \
        --allow-root
else
    wp theme install online-video-games \
        --activate \
        --path=/var/www/html \
        --allow-root
fi

chown -R www-data:www-data /var/www/html

mkdir -p /run/php

echo "Starting PHP-FPM..."
exec php-fpm8.2 -F
