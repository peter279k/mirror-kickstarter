#!/bin/bash
#Set install parameters values
. ./.env

green_color='\e[0;32m'
yellow_color='\e[0;33m'
rest_color='\e[0m'

if [ ${USER} != "root" ]; then
    sudo_prefix='sudo '
fi;

echo -e "${green_color}Welcome to the kickstarter for Composer mirror updater!${rest_color}"

echo -e "${green_color}Update composer/mirror repository form GitHub...${rest_color}"

${sudo_prefix}chown -R www-data:www-data $INSTALL_PREFIX/

cd $INSTALL_PREFIX/mirror/
git pull origin master --no-edit
php composer.phar install -n

echo "${yellow_color}Restarting worker...${rest_color}"
${sudo_prefix}systemctl restart supervisor

echo "${green_color}Update Composer Repository Mirror has been done.${rest_color}"
