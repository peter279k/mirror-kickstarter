#!/bin/bash

echo 'Welcom to manual Composer mirror resyncer...'

if [ ${USER} != "root" ]; then
    sudo_prefix='sudo '
fi;

echo 'Stopping supervisor service with systemctl...'
${sudo_prefix}systemctl stop supervisor

cd /var/www/html/mirror
echo 'Forcing recync the Composer mirrors...'

${sudo_prefix}./mirror.php --resync -v

if [ $? != 0 ]; then
    RED='\033[0;31m'
    echo -e "${RED}Sorry! The manual mirror resyncer has been unexpected error!${RED}"
    echo 'Please try to run this shell script again!'
    exit 1;
fi;

echo 'Runnig the manual Composer mirror resyncer has been done...'
echo 'Starting supervisor service with systemctl...'
${sudo_prefix}systemctl stop supervisor
