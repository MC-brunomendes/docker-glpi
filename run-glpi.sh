#!/bin/bash
[[ ! "$VERSION_GLPI" ]] \
        && VERSION_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)
PHP_VERSION=$(php -v | tac | tail -n 1 | cut -d " " -f 2 | cut -c 1-3)

VERSION_GLPI=9.4.6
SRC_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/tags/${VERSION_GLPI} | jq .assets[0].browser_download_url | tr -d \")
TAR_GLPI=$(basename ${SRC_GLPI})
FOLDER_GLPI=glpi/
FOLDER_WEB=/var/www/html/
GLPI_Installed=$(php /var/www/html/glpi/bin/console -v | tac | tail -n 1 | cut -d " " -f 3 | cut -c 1-5)



if [[ -z "${TIMEZONE}" ]]; then echo "TIMEZONE is unset";
        else echo "date.timezone = \"$TIMEZONE\"" > /etc/php/$PHP_VERSION/apache2/conf.d/timezone.ini;
fi

if [ "$(ls ${FOLDER_WEB}${FOLDER_GLPI})" ];
then
   if [ $GLPI_Installed = $VERSION_GLPI ]; then echo "GLPI is already installed and updated";
        else
                echo "GLPI Needs to be updated"
                wget -P ${FOLDER_WEB} ${SRC_GLPI} -q --show-progress
                tar -xzf ${FOLDER_WEB}${TAR_GLPI} -C ${FOLDER_WEB}
                rm -Rf ${FOLDER_WEB}${TAR_GLPI}
                chown -R www-data:www-data ${FOLDER_WEB}${FOLDER_GLPI}
                #runing database update procedures --- NEEDS TESTING
                echo "Runing database update"
                php ${FOLDER_WEB}${FOLDER_GLPI}/bin/console glpi:database:update
        fi

else
        wget -P ${FOLDER_WEB} ${SRC_GLPI} --show-progress
        tar -xzf ${FOLDER_WEB}${TAR_GLPI} -C ${FOLDER_WEB}
        rm -Rf ${FOLDER_WEB}${TAR_GLPI}
        chown -R www-data:www-data ${FOLDER_WEB}${FOLDER_GLPI}
fi


echo -e "<VirtualHost *:80>\n\tDocumentRoot /var/www/html/glpi\n\n\t<Directory /var/www/html/glpi>\n\t\tAllowOverride All\n\t\tOrder Allow,Deny\n\t\tAllow from all\n\t</Directory>\n\n\tErrorLog /var/log/apache2/error-glpi.log\n\tLogLevel warn\n\tCustomLog /var/log/apache2/access-glpi.log combined\n</VirtualHost>" > /etc/apache2/sites-available/000-default.conf
echo "*/2 * * * * www-data /usr/bin/php /var/www/html/glpi/front/cron.php &>/dev/null" >> /etc/cron.d/glpi

service cron start

a2enmod rewrite && service apache2 restart && service apache2 stop

/usr/sbin/apache2ctl -D FOREGROUND
