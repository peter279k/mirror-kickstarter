#!/bin/bash

green_color='\e[0;32m'
red_color='\e[0;31m'
rest_color='\e[0m'

echo -e "${green_color}Welcom to manual Composer mirror resyncer...${rest_color}"

if [ ${USER} != "root" ]; then
    sudo_prefix='sudo '
fi;

echo -e "${green_color}Stopping supervisor service with systemctl...${rest_color}"
${sudo_prefix}systemctl stop supervisor

cd /var/www/html/mirror
echo 'Forcing recync the Composer mirrors...'

${sudo_prefix}./mirror.php --resync -v

if [ $? != 0 ]; then
    echo -e "${red_color}Sorry! The manual mirror resyncer has been unexpected error!${rest_color}"
    echo -e "${red_color}Please try to run this shell script again!${rest_color}"
    exit 1;
fi;

echo -e "${green_color}Runnig the manual Composer mirror resyncer has been done...${rest_color}"

echo -e "${green_color}Starting supervisor service with systemctl...${rest_color}"
${sudo_prefix}systemctl sart supervisor
