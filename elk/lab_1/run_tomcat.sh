#!/bin/bash
sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps
#echo '<user name="admin" password="12345678" roles="admin,manager,admin-gui,manager-gui,manager-status" />' >>>> /etc/tomcat/tomcat-users.xml
sudo systemctl enable tomcat
sudo systemctl start tomcat