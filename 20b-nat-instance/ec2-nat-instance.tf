resource "aws_instance" "nat_instance" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t2.nano"
  subnet_id                   = aws_subnet.public_subnet_for_nat_instance.id
  associate_public_ip_address = true
  user_data                   = 

  # without source_dest_check = false, this EC2 instance won't be 
  # able to serve as a NAT device and will simply drop packets coming 
  # its way instead of forwarding them outbound to the internet gateway
  source_dest_check = false

  vpc_security_group_ids = [
    aws_security_group.security_group_for_NAT_instance.id
  ]

  tags = { Name = "NAT-instance", AMI = "ubuntu-ami" }
}

resource "aws_eip" "nat_elastic_IP" {
  domain = "vpc"
  tags = { Name = "nat_elastic_IP" }
}

resource "aws_eip_association" "nat" {
  allocation_id = aws_eip.nat_elastic_IP.id
  instance_id   = aws_instance.nat_instance.id
}