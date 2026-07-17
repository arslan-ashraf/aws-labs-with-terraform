resource "aws_instance" "nat" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.nano"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

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
    Name = "nat-instance"
  }
}