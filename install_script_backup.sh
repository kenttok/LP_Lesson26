#!/bin/bash

yum install epel-release -y
yum install borgbackup vim -y
useradd -m borg
sudo mkdir /var/backup
sudo chown -R borg:borg /var/backup/
sudo mkdir /home/borg/.ssh
sudo touch /home/borg/.ssh/authorized_keys
sudo chmod 700 /home/borg/.ssh
sudo chmod 600 /home/borg/.ssh/authorized_keys
sudo chown -R borg:borg  /home/borg/.ssh
