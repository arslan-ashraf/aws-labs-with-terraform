#!bin/bash

sudo apt update -y

# Enable IPv4 packet forwarding
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Apply the masquerade rule (Replace eth0 with your active interface)
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Keep rules active after a reboot
sudo apt-get install iptables-persistent -y
