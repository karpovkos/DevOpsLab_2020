#!/bin/bash

#---  turn off selinux and firewalld !important
sudo systemctl stop firewalld
sudo systemctl disable firewalld

sudo setenforce 0
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config

sudo DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=$API_KEY DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

#--- enable logging in datadog agent
sudo sed -i '/logs_enabled/a logs_enabled: true' /etc/datadog-agent/datadog.yaml

#--- set new web monitoring
cat << SCRIPT | sudo tee /etc/datadog-agent/conf.d/http_check.d/conf.yaml
instances:
  - name: onliner.by
    url: https://www.onliner.by/
SCRIPT

#--- set new config for log agent in DataDog

sudo mkdir /etc/datadog-agent/conf.d/logs.d
sudo chown dd-agent:dd-agent -R /etc/datadog-agent/conf.d/logs.d/

cat << SCRIPT | sudo tee /etc/datadog-agent/conf.d/logs.d/conf.yaml
logs:
  - type: file
    path: /var/log/tomcat/*
    service: tomcat
    source: tomcat
SCRIPT

sudo systemctl restart datadog-agent
sudo systemctl enable datadog-agent

sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps
sudo sed -i '/<\/tomcat-users>/i <user name="admin" password="12345678" roles="admin,manager,admin-gui,manager-gui,manager-status" \/>' /etc/tomcat/tomcat-users.xml

sudo chmod -R 775 /var/log/tomcat
sudo systemctl enable tomcat
sudo systemctl restart tomcat
