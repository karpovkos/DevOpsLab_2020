#!/bin/bash
sudo yum -y install openldap-clients nss-pam-ldapd
sudo authconfig --enableldap --enableldapauth --ldapserver=${server_adress} --ldapbasedn="dc=devopslab,dc=com" --enablemkhomedir --update

#--- change config sshd
sudo sed -i "/PasswordAuthentication/d" /etc/ssh/sshd_config
sudo echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
sudo echo 'AuthorizedKeysCommand /opt/ssh_ldap.sh' | sudo tee -a /etc/ssh/sshd_config
sudo echo 'AuthorizedKeysCommandUser nobody' | sudo tee -a /etc/ssh/sshd_config

#--- create ssh_ldap script
sudo tee /opt/ssh_ldap.sh <<SCRIPT
#!/bin/bash
set -eou pipefail
IFS=$'\n\t'

result=\$(ldapsearch -x '(&(objectClass=posixAccount)(uid='"\$1"'))' 'sshPublicKey')
attrLine=\$(echo "\$result" | sed -n '/^ /{H;d};/sshPublicKey:/x;\$g;s/\n *//g;/sshPublicKey:/p')

if [[ "\$attrLine" == sshPublicKey::* ]]; then
  echo "\$attrLine" | sed 's/sshPublicKey:: //' | base64 -d
elif [[ "\$attrLine" == sshPublicKey:* ]]; then
  echo "\$attrLine" | sed 's/sshPublicKey: //'
else
  exit 1
fi
SCRIPT
sudo chmod +x /opt/ssh_ldap.sh

#--- restart sshd & nslcd
sudo systemctl restart nslcd
sudo systemctl restart sshd