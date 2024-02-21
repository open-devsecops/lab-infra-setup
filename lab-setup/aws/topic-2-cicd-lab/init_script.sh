#!/bin/bash
set -e

# Update node.js
sudo npm install n -g
sudo n latest

# Run vpn-config-generator
npm install pm2 -g
git clone https://github.com/open-devsecops/vpn-config-generator.git 
cd vpn-config-generator
npm install
pm2 start index.js
cd ..

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get -y install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker compose -f /home/ubuntu/open-devsecops/docker-compose.yml up -d 

# # Install Artifactory
# wget -qO - https://releases.jfrog.io/artifactory/api/gpg/key/public | sudo apt-key add -
# echo "deb https://releases.jfrog.io/artifactory/artifactory-debs jammy main" | sudo tee -a /etc/apt/sources.list
# sudo apt-get update && sudo apt-get -y install jfrog-artifactory-jcr

# # Start Artifactory Service
# systemctl start artifactory.service


echo "Lab Infrastructure Provisioning Complete"
