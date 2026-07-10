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

cat << 'EOF' > index.html

EOF

cat << 'EOF' > server.js
const http = require('http');
const fs = require('fs');
const os = require('os');
const path = require('path');

let server_random_id = Math.floor(Math.random() * 1_000_000)

function isPrime(num) {
    if (num <= 1) return false;
    if (num === 2) return true;
    if (num % 2 === 0) return false;

    // Check odd factors up to the square root of the number
    const boundary = Math.sqrt(num);
    for (let i = 3; i <= boundary; i += 2) {
        if (num % i === 0) return false;
    }
    return true;
}

function find_nth_prime(n) {
    if (n < 1) return null;
    
    let count = 0;
    let num = 1;

    while (count < n) {
        num++;
        if (isPrime(num)) {
            count++;
        }
    }
    return num;
}

// Function to get the local IPv4 address of the machine
function getLocalIp() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address; // Returns the first non-internal IPv4 address
            }
        }
    }
    return '127.0.0.1'; // Fallback
}

const PORT = 80;
const serverIp = getLocalIp();

const server = http.createServer((req, res) => {
    // Read the HTML file
    fs.readFile(path.join(__dirname, 'index.html'), 'utf-8', (err, content) => {
        if (err) {
            res.writeHead(500, { 'Content-Type': 'text/plain' });
            res.end('Error loading index.html');
            return;
        }

        let large_prime = find_nth_prime(100_000)

        let random_number = Math.floor(Math.random() * 1_000_000)

        // Replace the placeholder with the actual server IP address
        const updatedHtml = content
                .replace('%% IP_ADDRESS %%', serverIp)
                .replace('%% SERVER_RANDOM_ID %%', server_random_id)
                .replace('%% LARGE_PRIME %%', large_prime)
                .replace('%% RANDOM_NUMBER %%', random_number)

        // Send the updated HTML to the browser
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(updatedHtml);
    });
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running at http://0.0.0.0:${PORT}`);

    console.log(`Also accessible on your network at http://${serverIp}:${PORT}`);
});
EOF

cat << 'EOF' > .dockerignore

EOF

cat << 'EOF' > Dockerfile

EOF

echo "#######################################################"

ls 

echo "############### BUILDING DOCKER IMAGE #################"

sudo docker build -t basic-app .

echo "############### RUNNING DOCKER CONTAINER ##############"

sudo docker run -p 80:3000 basic-app