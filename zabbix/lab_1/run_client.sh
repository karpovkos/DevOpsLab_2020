#!/bin/bash

sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum install -y zabbix-agent

cat << SCRIPT | sudo tee /etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=$server_adress
ServerActive=${server_adress}
Hostname=$HOSTNAME
HostMetadataItem=system.uname
Include=/etc/zabbix/zabbix_agentd.d/*.conf
SCRIPT

sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent

sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps
sudo sed -i '/<\/tomcat-users>/i <user name="admin" password="12345678" roles="admin,manager,admin-gui,manager-gui,manager-status" \/>' /etc/tomcat/tomcat-users.xml

sudo chmod -R 775 /var/log/tomcat
sudo systemctl enable logstash
sudo systemctl restart logstash