Content-Type: multipart/mixed; boundary="==EC2_CONFIG=="
MIME-Version: 1.0

--==EC2_CONFIG==
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--==EC2_CONFIG==
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.sh"

#!/bin/bash

echo "This script runs on every single boot!" >> /var/log/every-boot.log

--==EC2_CONFIG==--

# install Docker
# add Docker's official GPG key:
sudo apt update -y
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update -y

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo "Waiting for Docker daemon to be ready..."

# set a timeout limit (e.g., 30 seconds) for docker to respond
COUNTER=0
TIMEOUT=30

echo "Waiting for Docker daemon to respond..."
until sudo docker info >/dev/null 2>&1; do
    if [ "$COUNTER" -ge "$TIMEOUT" ]; then
        echo "Error: Docker daemon failed to start within $TIMEOUT seconds."
        exit 1
    fi
    
    let COUNTER=COUNTER+1
    sleep 1
done

echo "######### DOCKER SUCCESSFULLY INSTALLED AND READY #########"

# -p is --parent, no error if parent already exists
mkdir -p /home/ubuntu
cd /home/ubuntu

