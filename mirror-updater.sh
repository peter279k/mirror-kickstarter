#!/bin/bash

echo 'Welcome to the kickstarter for Composer mirror updater!'

echo 'Update composer/mirror repository form GitHub...'
${sudo_prefix}su -p -l www-data -s /bin/bash -c "cd /var/www/html/mirror/ && git pull origin master"
${sudo_prefix}su -p -l www-data -s /bin/bash -c "cd /var/www/html/mirror/ && composer install"

echo 'Update Composer Repository Mirror has been done.'
