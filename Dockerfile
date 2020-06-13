FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
&& apt -y upgrade \
&& apt -y install \
apache2 \
php \
php-mysql \
php-ldap \
php-xmlrpc \
php-imap \
curl \
php-curl \
php-gd \
php-mbstring \
php-xml \
php-apcu-bc \
php-cas \
cron \
wget \
jq \
vim \
nano

COPY run-glpi.sh /tmp/
RUN chmod +x /tmp/run-glpi.sh
ENTRYPOINT ["/tmp/run-glpi.sh"]
EXPOSE 80/tcp 443/tcp
#wget https://github.com/glpi-project/glpi/releases/download/9.5.0-rc1/glpi-9.5.0-rc1.tgz
#tar xvzf glpi-9.5.0-rc1.tgz -C /var/www/html
#rm -f glpi-9.5.0-rc1.tgz
