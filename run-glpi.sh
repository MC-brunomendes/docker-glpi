#!/bin/bash

[[ ! "$VERSION_GLPI" ]] \
	&& VERSION_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)

if [[ -z "${TIMEZONE}" ]]; then echo "TIMEZONE is unset";
else echo "date.timezone = \"$TIMEZONE\"" > /etc/php/7.3/apache2/conf.d/timezone.ini;
fi

SRC_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/tags/${VERSION_GLPI} | jq .assets[0].browser_download_url | tr -d \")
TAR_GLPI=$(basename ${SRC_GLPI})
FOLDER_GLPI=glpi/
FOLDER_WEB=/var/www/html/

if [ "$(ls ${FOLDER_WEB}${FOLDER_GLPI})" ];
then
        echo "GLPI is already installed"
else
        #wget -P ${FOLDER_WEB} ${SRC_GLPI}
        #tar -xzf ${FOLDER_WEB}${TAR_GLPI} -C ${FOLDER_WEB}
        #rm -Rf ${FOLDER_WEB}${TAR_GLPI}
        #fix 9.4.6
        wget -P /var/www/html/ https://github.com/glpi-project/glpi/releases/download/9.4.6/glpi-9.4.6.tgz
        tar -xzf ${FOLDER_WEB}glpi-9.4.6.tgz -C ${FOLDER_WEB}
        rm -Rf ${FOLDER_WEB}glpi-9.4.6.tgz


        chown -R www-data:www-data ${FOLDER_WEB}${FOLDER_GLPI}
fi
echo -e "<VirtualHost *:80>\n\tDocumentRoot /var/www/html/glpi\n\n\t<Directory /var/www/html/glpi>\n\t\tAllowOverride All\n\t\tOrder Allow,Deny\n\t\tAllow from all\n\t</Directory>\n\n\tErrorLog /var/log/apache2/error-glpi.log\n\tLogLevel warn\n\tCustomLog /var/log/apache2/access-glpi.log combined\n</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

#Add scheduled task by cron and enable
echo "*/2 * * * * www-data /usr/bin/php /var/www/html/glpi/front/cron.php &>/dev/null" >> /etc/cron.d/glpi
#Start cron service
service cron start

#Activation du module rewrite d'apache
a2enmod rewrite && service apache2 restart && service apache2 stop

#Lancement du service apache au premier plan
/usr/sbin/apache2ctl -D FOREGROUND
