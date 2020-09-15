#! /bin/bash
pass=password
network_range=${ip_cidr_range}

#--- install mariadb
sudo yum install -y mariadb mariadb-server
sudo /usr/bin/mysql_install_db --user=mysql
sudo systemctl start mariadb
sudo systemctl enable mariadb

#--- grant privileges on zabbix
mysql -uroot <<SCRIPT
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by '$pass'; 
SCRIPT

#--- install zabbix
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
# sudo yum clean all
sudo yum install -y centos-release-scl
sudo yum install -y zabbix-server-mysql zabbix-agent

####
sudo sed -i "0,/enabled=0/s/enabled=0/enabled=1/" /etc/yum.repos.d/zabbix.repo
sudo yum install -y zabbix-web-mysql-scl zabbix-apache-conf-scl
sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix --password=$pass zabbix


#--- configuration zabbix server 
cat <<SCRIPT | sudo tee /etc/zabbix/zabbix_server.conf
LogFile=/var/log/zabbix/zabbix_server.log
LogFileSize=0
PidFile=/var/run/zabbix/zabbix_server.pid
SocketDir=/var/run/zabbix
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=$pass
SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
Timeout=4
AlertScriptsPath=/usr/lib/zabbix/alertscripts
ExternalScripts=/usr/lib/zabbix/externalscripts
LogSlowQueries=3000
StatsAllowedIP=$network_range
SCRIPT

#--- set new time zone
sudo sed -i '/date.timezone/a php_value[date.timezone] = Europe\/Minsk' /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf

cat <<SCRIPT | sudo tee /etc/zabbix/web/zabbix.conf.php
<?php
\$DB['TYPE']             = 'MYSQL';
\$DB['SERVER']           = 'localhost';
\$DB['PORT']             = '0';
\$DB['DATABASE']         = 'zabbix';
\$DB['USER']             = 'zabbix';
\$DB['PASSWORD']         = '$pass';
\$DB['SCHEMA']           = '';
\$DB['ENCRYPTION']       = false;
\$DB['KEY_FILE']         = '';
\$DB['CERT_FILE']        = '';
\$DB['CA_FILE']          = '';
\$DB['VERIFY_HOST']      = false;
\$DB['CIPHER_LIST']      = '';
\$DB['DOUBLE_IEEE754']   = true;
\$ZBX_SERVER             = 'localhost';
\$ZBX_SERVER_PORT        = '10051';
\$ZBX_SERVER_NAME        = '$HOSTNAME';
\$IMAGE_FORMAT_DEFAULT   = IMAGE_FORMAT_PNG;
SCRIPT

#---  turn off selinux !important
sudo setenforce 0
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config

#--- restart services
sudo systemctl restart zabbix-server httpd rh-php72-php-fpm zabbix-agent
sudo systemctl enable zabbix-server httpd rh-php72-php-fpm zabbix-agent