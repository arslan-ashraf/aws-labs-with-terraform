resource "aws_instance" "nat_instance" {
  availability_zone           = values(local.public_subnets_for_NAT_instance)[0].AZ
  ami                         = var.NAT_instance_config.ami
  instance_type               = var.NAT_instance_config.instance_type
  subnet_id                   = aws_subnet.subnets_in_main_vpc[
    keys(local.public_subnets_for_NAT_instance)[0]
  ].id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.public_SSH_key.key_name
  user_data                   = file("${path.module}/nat_instance_user_data.sh")

  # without source_dest_check = false, this EC2 instance won't be 
  # able to serve as a NAT device and will simply drop packets coming 
  # its way instead of forwarding them outbound to the internet gateway
  source_dest_check = false

  vpc_security_group_ids = [
    aws_security_group.security_group_for_NAT_instance.id
  ]

  tags = { Name = "NAT-Instance", AMI = "ubuntu-ami" }
}

resource "aws_eip" "NAT_elastic_IP" {
  domain = "vpc"
  tags   = { Name = "NAT_elastic_IP" }
}

resource "aws_eip_association" "nat" {
  allocation_id = aws_eip.NAT_elastic_IP.id
  instance_id   = aws_instance.nat_instance.id
}

resource "aws_key_pair" "public_SSH_key" {
  key_name   = "key-for-ec2-connection"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}