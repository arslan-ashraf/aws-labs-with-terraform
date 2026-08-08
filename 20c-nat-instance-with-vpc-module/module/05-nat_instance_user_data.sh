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

# Enable IPv4 packet forwarding so the NAT instance can forward
# packets out to the internet
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

# to verify that indeed, the NAT instance can forward packets out:
# cat /proc/sys/net/ipv4/ip_forward # should print 1


sudo sysctl -p

# this command is what turns your EC2 instance into a NAT device
# it applies the 'masquerade' rule, here is the explanation:
# iptables: configures the Linux kernel's packet filtering and NAT rules
# -t nat: use the NAT table instead of the default filter table
# -A POSTROUTING: append (-A) a rule to the POSTROUTING chain
# -o $NETWORK_INTERFACE_NAME: match packets that are leaving this machine
# through the interface named $NETWORK_INTERFACE_NAME
# -j MASQUERADE: jump to MASQUERADE target, it rewrites the source IP
# from private instance's private IP to the NAT instance's public IP
# but you must get the actual active network interface, use the
# commands 'ip link' or 'ip route' to see the network interfaces
NETWORK_INTERFACE_NAME=$(ip route show default | awk '{print $5}')
sudo iptables -t nat -A POSTROUTING -o "$NETWORK_INTERFACE_NAME" -j MASQUERADE

# $NETWORK_INTERFACE_NAME might be "enX0" or "ens0" or "eth0", for example:
# sudo iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE

# note: command above 'ip route show default' might show:
# default via 10.0.5.1 dev enX0
# and piping that result into "awk '{print $5}'" pulls out the 
# network interface name which in this example is 'enX0'


# Keep rules active after a reboot
sudo apt-get install iptables-persistent -y

echo "###########################################################"
echo "################ USER DATA SCRIPT FINISHED ################"
echo "###########################################################"