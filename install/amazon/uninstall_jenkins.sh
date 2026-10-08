#!/bin/bash



sudo systemctl stop jenkins
sudo systemctl disable jenkins

# CentOS/RHEL
sudo yum remove jenkins -y

# Fedora / RHEL 8+
sudo dnf remove jenkins -y

sudo rm -rf /var/lib/jenkins
sudo rm -rf /var/log/jenkins
sudo rm -rf /var/cache/jenkins
sudo rm -rf /etc/sysconfig/jenkins
sudo rm -rf /etc/init.d/jenkins

# Remove repository
sudo rm -f /etc/yum.repos.d/jenkins.repo
sudo rpm --erase gpg-pubkey-$(rpm -q gpg-pubkey --qf "%{version}-%{release}\n" | grep jenkins)

#sudo userdel -r jenkins
#sudo groupdel jenkins
