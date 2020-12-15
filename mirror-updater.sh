#!/bin/bash

green_color='\e[0;32m'
rest_color='\e[0m'

echo -e "${green_color}Welcome to the kickstarter for Composer mirror updater!${rest_color}"

echo -e "${green_color}Update composer/mirror repository form GitHub...${rest_color}"

${sudo_prefix}su -p -l www-data -s /bin/bash -c "cd /var/www/html/mirror/ && git pull origin master"
${sudo_prefix}su -p -l www-data -s /bin/bash -c "cd /var/www/html/mirror/ && composer install"

echo "${green_color}Update Composer Repository Mirror has been done.${rest_color}"
