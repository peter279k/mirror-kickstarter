#!/bin/bash

RED='\033[0;31m'
echo 'Welcome to the kickstarter for Composer mirror setup!'
echo -e "${RED}Please notice that this server will be a clean/new operating system!${RED}"
echo 'Detect Linux distribution...'
echo -e "${RED}Just notice that this kickstarter supports Ubuntu 18.04 and Ubuntu 20.04 for now...${RED}"

echo 'Check whether user is root...'
if [ ${USER} != "root" ]; then
    sudo_prefix='sudo '
fi;

${sudo_prefix}apt-get update
${sudo_prefix}apt-get install -y software-properties-common

echo 'Import fingerprint key for remote PHP mirror...'
${sudo_prefix}apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C

echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu ${lsb_release -c | awk '{print $2}'} main" | ${sudo_prefix}tee -a /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/ondrej/php/ubuntu ${lsb_release -c | awk '{print $2}'} main" | ${sudo_prefix}tee -a /etc/apt/sources.list

echo 'Import key for remote Nginx mirror...'
echo "deb http://ppa.launchpad.net/ondrej/nginx/ubuntu ${lsb_release -c | awk '{print $2}'} main" | ${sudo_prefix}tee -a /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/ondrej/nginx/ubuntu ${lsb_release -c | awk '{print $2}'} main" | ${sudo_prefix}tee -a /etc/apt/sources.list

echo 'Install required packages...'
${sudo_prefix}apt-get update
${sudo_prefix}apt-get -y install git zip unzip supervisor nginx
${sudo_prefix}apt-get install -y apt-transport-https apt-utils curl git php7.4-cli php7.4-mysql php7.4-curl
${sudo_prefix}apt-get install -y php7.4-xml php7.4-zip php7.4-mbstring php7.4-dom php7.4-xsl php7.4-json php7.4-fpm nginx

echo 'Start supervisor service with systemctl...'
${sudo_prefix}systemctl enable --now supervisor

echo 'Download Composer...'
curl -sS https://getcomposer.org/installer | php
${sudo_prefix}mv composer.phar /usr/local/bin/composer

echo 'Copy Nginx configuration file...'
${sudo_prefix}cp ./nginx-default.conf /etc/nginx/sites-available/default

${sudo_prefix}rm -rf ./*
${sudo_prefix}su -p -l www-data -s /bin/bash -c "cd /var/www/html/ && git clone https://github.com/composer/mirror mirror"
${sudo_prefix}su -p -l www-data -s /bin/bash -c "cd /var/www/html/mirror/ && composer install -n"

echo 'More informations about Composer mirror setting, please refer the https://github.com/composer/mirror :-)'
echo 'Or run mirror-installer.sh script!'
