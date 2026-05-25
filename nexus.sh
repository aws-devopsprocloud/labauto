#!/bin/bash 

sudo dnf install java-17-openjdk -y

curl -L https://download.sonatype.com/nexus/3/latest-unix.tar.gz -o /tmp/nexus.tar.gz

sudo tar -xzf /tmp/nexus.tar.gz -C /opt
sudo mv /opt/nexus-3.* /opt/nexus

sudo useradd -r -s /bin/bash nexus
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work


sudo vi /opt/nexus/bin/nexus.rc
# Add or uncomment the following line:
run_as_user="nexus"

sudo cp /home/ec2-user/labauto/nexus.service /etc/systemd/system/nexus.service

sudo systemctl daemon-reload
sudo systemctl enable --now nexus

sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload


