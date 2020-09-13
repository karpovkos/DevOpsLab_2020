#!/bin/bash
sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps
sudo sed -i '/<\/tomcat-users>/i <user name="admin" password="12345678" roles="admin,manager,admin-gui,manager-gui,manager-status" \/>' /etc/tomcat/tomcat-users.xml

sudo systemctl enable tomcat
sudo systemctl start tomcat

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat << SCRIPT | sudo tee /etc/yum.repos.d/logstash.repo
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
SCRIPT

sudo  yum install -y logstash
cat << SCRIPT | sudo tee /etc/logstash/conf.d/tomcat.conf
input {
  file {
    path => "/var/log/tomcat/*"
    start_position => "beginning"
  }
}

output {
  elasticsearch {
    hosts => ["${server_adress}:9200"]
  }
  stdout { codec => rubydebug }
}
SCRIPT

sudo chmod -R 775 /var/log/tomcat
sudo systemctl enable logstash
sudo systemctl restart logstash