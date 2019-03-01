#!/bin/bash
# setup-lnxcfg-user
# create lnxcfg user for Ansible automation
# and configuration management

# create lnxcfg user
getentUser=$(/usr/bin/getent passwd lnxcfg)
if [ -z "$getentUser" ]
then
  echo "User lnxcfg does not exist.  Will Add..."
  /usr/sbin/groupadd -g 2002 lnxcfg
  /usr/sbin/useradd -u 2002 -g 2002 -c "Ansible Automation Account" -s /bin/bash -m -d /home/lnxcfg lnxcfg

echo "lnxcfg:LifeTime1234" | /sbin/chpasswd

mkdir -p /home/lnxcfg/.ssh

fi

# setup ssh authorization keys for Ansible access 
echo "setting up ssh authorization keys..."

cat << 'EOF' >> /home/lnxcfg/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjIsQKBsJzryJh9zvNY7TsbecrHFsFcqUAiNlgWqt+vPreP2ZGCZHAv1626VjMZkDNpqugUHFeHE5+38+ZswJmnHZxRgpPkvS41lp7OjRhoq/Lra8uWjHozysiVzOVZ+y2yHP30Aw3xVhy8HcZIMv+RkUySOUv+G5eSj4VDx8hLgvuw1ESPzGHSP0xZXJUe32H+SgXbRLYFPDicodAS0eRpqZtmhTngvlSEIEYjB4KMLC3rBsufbN3muVGTD1fjtsTwtGnSwLxg//zBIFArdO5uBypkI52gadTpiDKtTc3qz79Dwcr0aNaA1XjJSRuC1KH1n/c9DCIGlwRJAFku4mB
EOF

chown -R lnxcfg:lnxcfg /home/lnxcfg/.ssh
chmod 700 /home/lnxcfg/.ssh

# setup sudo access for Ansible
if [ ! -s /etc/sudoers.d/lnxcfg ]
then
echo "User lnxcfg sudoers does not exist.  Will Add..."
cat << 'EOF' > /etc/sudoers.d/lnxcfg
User_Alias ANSIBLE_AUTOMATION = %lnxcfg
ANSIBLE_AUTOMATION ALL=(ALL)      NOPASSWD: ALL
EOF
chmod 400 /etc/sudoers.d/lnxcfg
fi

# disable login for lnxcfg except through 
# ssh keys
cat << 'EOF' >> /etc/ssh/sshd_config
Match User lnxcfg
        PasswordAuthentication no
        AuthenticationMethods publickey

EOF

# restart sshd
systemctl restart sshd

# end of script
