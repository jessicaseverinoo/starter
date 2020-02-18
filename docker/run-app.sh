#!/usr/bin/env bash

set -e

env=${APP_ENV:-production}
role=${CONTAINER_ROLE:-app}

echo "Permission configuration..."
chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache \
    && chown -R www-data:1000 /var/www/html \
    && usermod -u 1000 www-data

echo "The role is $role..."

# App
if [ "$role" = "app" ]; then
    if [ "$env" != "local" ]; then
        echo "Caching..."
        (cd /var/www/html && php artisan admix:optimize)
    else
        echo "Cleaning cache..."
        (cd /var/www/html && php artisan optimize:clear)
    fi

    (cd /var/www/html && php artisan storage:link)
    exec apache2-foreground

## Scheduler
elif [ "$role" = "scheduler" ]; then

    ln -sf /etc/supervisor/conf.d-available/scheduler.conf /etc/supervisor/conf.d/scheduler.conf

## Queue
elif [ "$role" = "queue" ]; then

    ln -sf /etc/supervisor/conf.d-available/queue.conf /etc/supervisor/conf.d/queue.conf

else
    echo "Could not match the container role \"$role\""
    exit 1
fi

exec supervisord -c /etc/supervisor/supervisord.conf
