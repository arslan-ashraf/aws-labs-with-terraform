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

sudo apt update -y

# Enable IPv4 packet forwarding
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Apply the masquerade rule (Replace eth0 with your active interface)
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Keep rules active after a reboot
sudo apt-get install iptables-persistent -y