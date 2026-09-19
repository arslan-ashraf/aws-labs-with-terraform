Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0
    
--==BOUNDARY==
Content-Type: text/cloud-config; charset="us-ascii"
    
#cloud-config
cloud_final_modules:
- [scripts-user, always]
    
--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash

echo "###########################################################"
echo "################# USER DATA SCRIPT RUNNING ################"
echo "###########################################################"

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

echo "###########################################################"
echo "######### DOCKER SUCCESSFULLY INSTALLED AND READY #########"
echo "###########################################################"

# -p is --parent, no error if parent already exists
mkdir -p /home/ubuntu
cd /home/ubuntu

cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Basic NodeJS Server</title>
</head>
<body style="font-family: sans-serif; text-align: center; margin-top: 50px; margin-left: 40px; background-color: lightorange; text-align: left">
    <h1>NodeJS Server Running</h1>

    <h1>Docker Provided Virtual IP Address: <strong id="ip-address"></strong></h1>

    <h1>Server ID Randomly Generated to Distinguish Different Servers: <strong id="server-random-id"></strong></h1>

    <h1>A Large Prime Number: <strong id="large-prime"></strong></h1>

    <h1>Some Random Number to Distinguish Different Requests: <strong id="random-number"></strong></h1>

    <script>
        document.getElementById('ip-address').textContent = "%% IP_ADDRESS %%"

        document.getElementById('server-random-id').textContent = "%% SERVER_RANDOM_ID %%"

        document.getElementById('large-prime').textContent = "%% LARGE_PRIME %%"

        document.getElementById('random-number').textContent = "%% RANDOM_NUMBER %%"
    </script>
</body>
</html>
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

        let large_prime = find_nth_prime(5_000)

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

server.listen(PORT, () => {
    console.log(`Server is running at http://localhost:${PORT}`);
});
EOF

cat << 'EOF' > .dockerignore
node_modules
npm-debug.log
.dockerignore
Dockerfile
ansible_dockerfile
EOF

cat << 'EOF' > Dockerfile
FROM node:current-alpine3.24

WORKDIR /app

COPY server.js index.html .

EXPOSE 80

CMD ["node", "server.js"]
EOF

echo "#######################################################"
echo "#######################################################"
echo "#######################################################"

ls 

echo "#######################################################"
echo "############### BUILDING DOCKER IMAGE #################"
echo "#######################################################"

sudo docker build -t basic-app .

echo "#######################################################"
echo "############### RUNNING DOCKER CONTAINER ##############"
echo "#######################################################"

sudo docker run -p 80:80 basic-app


echo "#######################################################"
echo "################# APP SERVER RUNNING ##################"
echo "#######################################################"


echo "#######################################################"
echo "################# PREPARING ANSIBLE ###################"
echo "#######################################################"

mkdir inventory

cat << 'EOF' > inventory/production_servers.yaml
backend_servers:
  hosts:
    <server_IP_address>:
      ansible_user: ubuntu
      ansible_ssh_private_key_file: /keys/key-for-ec2-connection
EOF


cat << 'EOF' > ansible.cfg
[defaults]

host_key_checking = False

inventory = inventory/production_servers.yaml
EOF


cat << 'EOF' > custom_facts.fact
#!/bin/bash

docker_version=$(docker --version | awk '{print $3}')

cat << 'EOF_DOCKER_VERSION'
{
    "DOCKER_VERSION": "$docker_version"
}
EOF_DOCKER_VERSION
EOF


cat << 'EOF' > playbook.yaml
- name: First cloud play
  hosts: backend_servers             # must match in the inventory
  tasks:
    - name: Ping server
      ansible.builtin.ping:

    - name: Print builtin variables
      ansible.builtin.debug:
        msg: {
          "ansible_check_mode": "{{ ansible_check_mode }}",
          "ansible_diff_mode": "{{ ansible_diff_mode }}",
          "ansible_version": "{{ ansible_version['full'] }}",
          "inventory_dir": "{{ inventory_dir }}",
          "inventory_file": "{{ inventory_file }}",
          "inventory_hostname": "{{ inventory_hostname }}",
          "playbook_dir": "{{ playbook_dir }}"
        }

- name: Create facts.d directory and copy custom facts file
  hosts: backend_servers             # must match in the inventory
  tasks:
    - name: Create facts.d directory
      ansible.builtin.file:
        path: /etc/ansible/facts.d
        state: directory          # ensure this is a directory
        mode: '0755'              # sets directory permissions
        owner: ubuntu             # optional: sets directory owner
        group: ubuntu             # optional: sets directory group

    - name: Copying custom facts file
      ansible.builtin.copy:
        src: custom_facts.fact
        dest: /etc/ansible/facts.d
        mode: '0755'               # set file permissions
        owner: ubuntu              # optional: sets file owner
        group: ubuntu              # optional: sets file group
EOF

cat << 'EOF' > ansible_dockerfile
FROM python:3.11-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-client \
    sshpass \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir ansible-core

WORKDIR /ansible

RUN mkdir /ansible/inventory

# /ansible directory has full permissions so, ansible ignores the ansible.cfg file
# insufficient, need ENV or permission change
COPY ansible.cfg /ansible
COPY playbook.yaml /ansible
COPY inventory/production_servers.yaml /ansible/inventory

# bypasses the permissions check
ENV ANSIBLE_CONFIG=/ansible/ansible.cfg

# or change permissions so only the owner can write to it
# RUN chmod 755 /ansible && chmod 644 /ansible/ansible.cfg

CMD ["ansible", "--version"]
EOF


echo "#######################################################"
echo "########### BUILDING ANSIBLE DOCKER IMAGE #############"
echo "#######################################################"

sudo docker build -t my-ansible-core -f ansible_dockerfile


echo "#######################################################"
echo "########### RUNNING ANSIBLE DOCKER CONTAINER ##########"
echo "#######################################################"

sudo docker run --rm -it \
  -v $(pwd):/ansible \
  my-ansible-core


echo "#######################################################"
echo "############### PING SERVER WITH ANSIBLE ##############"
echo "#######################################################"

docker run --rm -it \
  -v $(pwd):/ansible \
  -v "/key-for-ec2-connection:/keys/key-for-ec2-connection:ro" \
  my-ansible-core \
  ansible backend-servers -m ping


ansible-playbook playbook.yaml