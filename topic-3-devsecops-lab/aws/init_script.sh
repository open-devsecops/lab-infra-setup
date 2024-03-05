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

# Intall Postgres
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt-get install -y postgresql
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Install SonarQube

## Configure Postgres
echo "***** Configuring Postgres for SonarQube *****" 
sudo -u postgres psql << EOF
CREATE USER sonarqube WITH PASSWORD 'Password';
CREATE DATABASE sonarqube OWNER sonarqube;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;
EOF

echo "***** Installing SonarQube *****" 
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.1.88267.zip
unzip sonarqube-10.4.1.88267.zip
rm sonarqube-10.4.1.88267.zip
mv sonarqube-10.4.1.88267 sonarqube
mv sonarqube /opt

sudo useradd -s /bin/bash sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

echo "sonar.jdbc.username=sonarqube" >> /opt/sonarqube/conf/sonar.properties
echo "sonar.jdbc.password=Password" >> /opt/sonarqube/conf/sonar.properties
echo "sonar.web.host=127.0.0.1" >> /opt/sonarqube/conf/sonar.properties
echo "sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube" >> /opt/sonarqube/conf/sonar.properties
sed -i '2s/^/RUN_AS_USER=sonarqube\n/' /opt/sonarqube/bin/linux-x86-64/sonar.sh

sudo bash -c "echo 'vm.max_map_count=524288' >> /etc/sysctl.conf && echo 'fs.file-max=131072' >> /etc/sysctl.conf && sysctl -p"

sudo cat > /etc/systemd/system/sonarqube.service << EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=65536
LimitNPROC=4096
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable sonarqube
sudo systemctl restart sonarqube

# Install Trivy
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install -y trivy


echo "Lab Infrastructure Provisioning Complete"
