#!/bin/bash

echo 'Please make sure the kickstarter.sh has been run!'
echo 'Changing directory to /var/www/html...'

if [ ${USER} != "root" ]; then
    sudo_prefix='sudo '
fi;

cd /var/www/html/mirror
if [ ! -f mirror.config.php ]; then
    echo 'Please create the mirror.config.php on /var/www/html folder manually!'
    echo 'More details about mirror.config.php setting is avaialbe on https://github.com/composer/mirror#composer-repository-mirror'
    exit 1;
fi;

echo 'Create a supervisor confiuration for mirrorv2....'
supervisor_path='/etc/supervisor/conf.d/composer-mirror-v2.conf'
${sudo_prefix}touch ${supervisor_path}

echo '[program:composer-mirror-v2]' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'command=php /var/www/html/mirror/mirror.php --v2' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'autostart=true' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'autorestart=true' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'user=root' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'redirect_stderr=true' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'stdout_logfile=/var/log/composer-mirror-v2.log' | ${sudo_prefix}tee -a ${supervisor_path}

echo 'Checking the has_v1_mirror is set for false on mirror.config.php...'
has_v1_mirror=$(cat /var/www/repov2.packagist.tw/mirror.config.php | grep 'has_v1_mirror' | sed 's/[, ]//g' | awk '{split($1, a, "=>"); print a[2]}')

if [ ${has_v1_mirror} == 'true' ]; then
    echo 'Create a supervisor confiuration for mirrorv1....'
    supervisor_path='/etc/supervisor/conf.d/composer-mirror-v1.conf'
    ${sudo_prefix}touch ${supervisor_path}

    echo '[program:composer-mirror-v1]' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'command=php /var/www/html/mirror/mirror.php --v1' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'autostart=true' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'autorestart=true' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'user=root' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'redirect_stderr=true' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'stdout_logfile=/var/log/composer-mirror-v1.log' | ${sudo_prefix}tee -a ${supervisor_path}

    echo 'Create a Cron job file for running "./mirror.php --gc" command once an hour...'
    echo 'SHELL=/bin/sh' | ${sudo_prefix}tee -a ${supervisor_path}
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' | ${sudo_prefix}tee -a ${supervisor_path}
    echo '*/60 * * * * root cd /var/www/html/mirror/ && php ./mirror.php --gc' | ${sudo_prefix}tee -a ${supervisor_path}
fi;

echo 'Restart supervisor service with systemctl...'

${sudo_prefix}systemctl restart supervisor

echo 'Mirror installer has been done!'
