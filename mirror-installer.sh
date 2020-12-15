#!/bin/bash

green_color='\e[0;32m'
yellow_color='\e[0;33m'
red_color='\e[0;31m'
rest_color='\e[0m'

echo -e "${yellow_color}Please make sure the kickstarter.sh has been run!${rest_color}"
echo -e "${green_color}Changing directory to /var/www/html...${rest_color}"

if [ ${USER} != "root" ]; then
    sudo_prefix='sudo '
fi;

if [ ! -f "${PWD}/mirror.config.php" ]; then
    echo -e "${red_color}Please create the mirror.config.php on ${PWD} directory manually!${rest_color}"
    echo -e "${red_color}More details about mirror.config.php setting is avaialbe on https://github.com/composer/mirror#composer-repository-mirror${rest_color}"
    exit 1;
fi;

cp "${PWD}/mirror.config.php" /var/www/html/mirror/

${sudo_prefix}chown -R www-data:www-data /var/www/html/
${sudo_prefix}chmod -R ug+rwx /var/www/html/mirror/

echo -e "${green_color}Create a supervisor confiuration for mirrorv2....${rest_color}"
supervisor_path="/etc/supervisor/conf.d/composer-mirror-v2.conf"
${sudo_prefix}touch ${supervisor_path}

echo '[program:composer-mirror-v2]' | ${sudo_prefix}tee ${supervisor_path}
echo 'command=php /var/www/html/mirror/mirror.php --v2' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'autostart=true' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'autorestart=true' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'user=root' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'redirect_stderr=true' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'stdout_logfile=/var/log/composer-mirror-v2.log' | ${sudo_prefix}tee -a ${supervisor_path}

echo -e "${green_color}Checking the has_v1_mirror is set for false on mirror.config.php...${rest_color}"
has_v1_mirror=$(cat /var/www/repov2.packagist.tw/mirror.config.php | grep 'has_v1_mirror' | sed 's/[, ]//g' | awk '{split($1, a, "=>"); print a[2]}')

if [ ${has_v1_mirror} == 'true' ]; then
    echo -e "${green_color}Create a supervisor confiuration for mirrorv1....${rest_color}"
    supervisor_path='/etc/supervisor/conf.d/composer-mirror-v1.conf'
    ${sudo_prefix}touch ${supervisor_path}

    echo '[program:composer-mirror-v1]' | ${sudo_prefix}tee ${supervisor_path}
    echo 'command=php /var/www/html/mirror/mirror.php --v1' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'autostart=true' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'autorestart=true' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'user=root' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'redirect_stderr=true' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'stdout_logfile=/var/log/composer-mirror-v1.log' | ${sudo_prefix}tee -a ${supervisor_path}

    echo -e "${green_color}Create a composer-mirror Cron job file for running ./mirror.php --gc command once an hour...${rest_color}"

    cronjob_path="/etc/cron.d/composer-mirror"
    echo 'SHELL=/bin/bash' | ${sudo_prefix}tee ${cronjob_path}
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' | ${sudo_prefix}tee -a ${cronjob_path}
    echo '*/60 * * * * root cd /var/www/html/mirror/ && php ./mirror.php --gc' | ${sudo_prefix}tee -a ${cronjob_path}
fi;

echo -e "${green_color}Restart supervisor service with systemctl...${rest_color}"

${sudo_prefix}systemctl restart supervisor

echo -e "${green_color}Mirror installer has been done!${rest_color}"

echo "${green_color}Setting up the composer-mirror-updater Cronjob file...${rest_color}"
echo "${green_color}Copying the mirror-updater.sh file to home root directory...${rest_color}"

${sudo_prefix}cp ${PWD}/mirror-updater.sh /root/
cronjob_path="/etc/cron.d/composer-mirror-updater"

echo 'SHELL=/bin/bash' | ${sudo_prefix}tee ${cronjob_path}
echo 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' | ${sudo_prefix}tee -a ${cronjob_path}
echo '*/60 * * * * root cd /root/ && ./mirror-updater.sh' | ${sudo_prefix}tee -a ${cronjob_path}

echo -e "${green_color}Adding composer-mirror-updater Cronjob file has been done!${rest_color}"
