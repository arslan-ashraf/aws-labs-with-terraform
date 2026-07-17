resource "aws_instance" "nat_instance" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.nano"
  subnet_id                   = aws_subnet.public_subnet_for_nat_instance.id
  associate_public_ip_address = true

  # without source_dest_check = false, this EC2 instance won't be 
  # able to serve as a NAT device and will simply drop packets coming 
  # its way instead of forwarding them outbound to the internet gateway
  source_dest_check = false

  vpc_security_group_ids = [
    aws_security_group.nat.id
  ]

  user_data = <<-EOF
#!/bin/bash
dnf install -y iptables-services

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ipforward.conf
sysctl --system

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
service iptables save
systemctl enable iptables
EOF

  tags = {
    Name = "NAT-Instance"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_eip_association" "nat" {
  allocation_id = aws_eip.nat.id
  instance_id   = aws_instance.nat.id
}