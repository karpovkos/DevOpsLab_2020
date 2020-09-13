#! /bin/bash

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

#--- install elasticsearch
sudo cat<<SCRIPT >/etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
SCRIPT

sudo yum -y install --enablerepo=elasticsearch elasticsearch

#--- cofiguration elasticsearch
sudo cat<<SCRIPT >>/etc/elasticsearch/elasticsearch.yml
network.host: 0.0.0.0
discovery.type: single-node
SCRIPT

sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service


#--- install kibana

sudo cat<<SCRIPT >/etc/yum.repos.d/kibana.repo
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
SCRIPT

sudo yum install kibana -y
sudo echo -e "\nserver.host: "0.0.0.0"" >> /etc/kibana/kibana.yml

sudo systemctl daemon-reload
sudo systemctl enable kibana.service
sudo systemctl restart kibana.service