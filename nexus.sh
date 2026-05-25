#!/bin/bash

set -e

# Install Java
sudo dnf install java-17-openjdk wget -y

# Download Nexus
curl -L https://download.sonatype.com/nexus/3/latest-unix.tar.gz -o /tmp/nexus.tar.gz

# Extract Nexus
sudo tar -xzf /tmp/nexus.tar.gz -C /opt

NEXUS_DIR=$(find /opt -maxdepth 1 -type d -name "nexus-3*" | head -1)

sudo mv "$NEXUS_DIR" /opt/nexus

# Create nexus user if not exists
id nexus &>/dev/null || sudo useradd -r -s /bin/bash nexus

# Create work directory
sudo mkdir -p /opt/sonatype-work

# Permissions
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work

# Configure nexus.rc
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

sudo bash -c "cat > /opt/nexus/bin/nexus.rc <<EOF
run_as_user=\"nexus\"
INSTALL4J_JAVA_HOME=$JAVA_HOME
EOF"

# Install systemd service
sudo cp /home/ec2-user/labauto/nexus.service /etc/systemd/system/nexus.service

# Reload systemd
sudo systemctl daemon-reload

# Enable and start Nexus
sudo systemctl enable --now nexus

# Open firewall port if firewalld exists
if systemctl is-active firewalld &>/dev/null; then
    sudo firewall-cmd --permanent --add-port=8081/tcp
    sudo firewall-cmd --reload
fi

echo "Nexus installation completed"

