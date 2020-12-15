#!/bin/bash

green_color='\e[0;32m'
yellow_color='\e[0;33m'
rest_color='\e[0m'

if [ ${USER} != "root" ]; then
    sudo_prefix='sudo '
fi;

echo -e "${green_color}Welcome to the kickstarter for Composer mirror updater!${rest_color}"

echo -e "${green_color}Update composer/mirror repository form GitHub...${rest_color}"

${sudo_prefix}chown -R www-data:www-data /var/www/html/

${sudo_prefix}su -p -l www-data -s /bin/bash -c "cd /var/www/html/mirror/ && git pull origin master --no-edit"
${sudo_prefix}su -p -l www-data -s /bin/bash -c "cd /var/www/html/mirror/ && php composer.phar install"

echo "${yellow_color}Restarting worker...${rest_color}"
${sudo_prefix}systemctl restart supervisor

echo "${green_color}Update Composer Repository Mirror has been done.${rest_color}"
