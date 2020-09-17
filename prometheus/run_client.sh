#!/bin/bash

#---  turn off selinux and firewalld !important
sudo systemctl stop firewalld
sudo systemctl disable firewalld

sudo setenforce 0
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker

sudo docker run -d -p 9100:9100 --name node-exporter --restart always prom/node-exporter