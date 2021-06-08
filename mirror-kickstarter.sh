#!/bin/bash
#Set install parameters values
. ./.env

green_color='\e[0;32m'
yellow_color='\e[0;33m'
red_color='\e[0;31m'
rest_color='\e[0m'

echo -e "${green_color}Welcome to the kickstarter for Composer mirror setup!${rest_color}"
echo -e "${green_color}Please notice that this server will be a clean/new operating system!${rest_color}"

echo -e "${yellow_color}Just notice that this kickstarter supports Ubuntu 18.04 and Ubuntu 20.04 for now...${rest_color}"

echo -e "${green_color}Check whether user is root...${rest_color}"
if [ ${USER} != "root" ]; then
    sudo_prefix='sudo '
fi;

${sudo_prefix}apt-get update
${sudo_prefix}apt-get install -y software-properties-common

echo -e "${green_color}Install required packages...${rest_color}"
${sudo_prefix}apt-get update
${sudo_prefix}apt-get -y install git curl zip unzip supervisor nginx tzdata locales ufw cron wget gzip
${sudo_prefix}apt-get install -y apt-transport-https apt-utils php7.4-cli php7.4-mysql php7.4-curl
${sudo_prefix}apt-get install -y php7.4-xml php7.4-zip php7.4-mbstring php7.4-dom php7.4-xsl php7.4-json php7.4-fpm nginx

echo -e "${green_color}Setup system locale setting...${rest_color}"

${sudo_prefix}locale-gen "en_US.UTF-8"
echo 'LC_ALL="en_US.UTF-8"' | ${sudo_prefix}tee /etc/default/locale
echo 'LANG="en_US.UTF-8"' | ${sudo_prefix}tee /etc/default/locale

echo -e "${green_color}Setup system timezone with interactive...${rest_color}"

${sudo_prefix}dpkg-reconfigure tzdata

echo -e "${green_color}Start supervisor service with systemctl...${rest_color}"
${sudo_prefix}systemctl enable --now supervisor

echo -e "${green_color}Download Composer...${rest_color}"
curl -sS https://getcomposer.org/installer | php

nginx_root_dir=$(grep root ${PWD}/nginx-default.conf|cut -d" " -f2)
nginx_root_dir=${nginx_root_dir::-1} #delete trailing ;
if [[ ${nginx_root_dir} != $INSTALL_PREFIX ]]; then
  echo -e "${red_color}Error between .env and ${PWD}/nginx-default.conf : INSTALL_PREFIX and NGINX root dir are different${rest_color}"
  exit 1
fi

echo -e "${green_color}Copy Nginx configuration file...${rest_color}"
${sudo_prefix}cp ./nginx-default.conf /etc/nginx/sites-available/default

read -p "Do you want to purge $INSTALL_PREFIX folder ? [Y/n] " purge_answer

if [[ ${purge_answer} == "Y" || ${install_answer} == "y" ]]; then
  ${sudo_prefix}rm -rf $INSTALL_PREFIX/*
  ${sudo_prefix}rm -rf $INSTALL_PREFIX/.* 2> /dev/null
fi

${sudo_prefix}chown -R www-data:www-data $INSTALL_PREFIX/
composer_path="${PWD}/composer.phar"

cd $INSTALL_PREFIX/
${sudo_prefix}git clone https://github.com/composer/mirror mirror
${sudo_prefix}mv ${composer_path} $INSTALL_PREFIX/mirror/

cd mirror/ && ${sudo_prefix}php composer.phar install -n

echo -e "${green_color}More informations about Composer mirror setting, please refer the https://github.com/composer/mirror :-)${rest_color}"
echo -e "${yellow_color}Or run mirror-installer.sh script!${rest_color}"

read -p "Do you want to install and configure Let's encrypt x3 SSL with Certbot? [Y/n] " install_answer

if [[ ${install_answer} == "Y" || ${install_answer} == "y" ]]; then
  echo -e "${green_color}Install required packages...${rest_color}"

  if [[ $(lsb_release -sc) == "bionic" ]]; then
    ${sudo_prefix}apt-get update
    ${sudo_prefix}apt-get install -y software-properties-common
    ${sudo_prefix}add-apt-repository universe
    ${sudo_ptrfix}add-apt-repository -y ppa:certbot/certbot
    ${sudo_prefix}apt-get update
  fi;

  ${sudo_prefix}apt-get install -y certbot python3-certbot-nginx

  echo -e "${green_color}Start generating and configuring cert automatically...${rest_color}"
  ${sudo_prefix}certbot --nginx

  if [[ $? != 0 ]]; then
    echo -e "${red_color}Something error happen during certbot running... Stopped.${rest_color}"
    exit 1;
  fi;

  echo "00  23 * * *  certbot renew --dry-run" | ${sudo_prefix}tee /var/spool/cron/crontabs/root
  ${sudo_prefix}chmod 0600 /var/spool/cron/crontabs/root
  ${sudo_prefix}systemctl restart cron
 
  ${sudo_prefix}ufw status | grep inactive

  if [[ $? != 0 ]]; then
    ${sudo_prefix}ufw allow https
  fi;
fi;

${sudo_prefix}ufw status | grep inactive

if [[ $? != 0 ]]; then
    ${sudo_prefix}ufw allow http
fi;

echo -e "${green_color}Installing mirror kickstarter has been done!${rest_color}"
