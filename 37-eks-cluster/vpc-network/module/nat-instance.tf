resource "aws_instance" "nat_instance" {
  ami                         = "ami-0ec10929233384c7f"
  region                      = "us-east-1"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.nano"
  subnet_id                   = aws_subnet.public_subnet_for_NAT_instance.id
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

  tags = { Name = "NAT-instance", AMI = "ubuntu-ami" }
}

resource "aws_eip" "nat_elastic_IP" {
  domain = "vpc"
  tags   = { Name = "nat_elastic_IP" }
}

resource "aws_eip_association" "nat" {
  allocation_id = aws_eip.nat_elastic_IP.id
  instance_id   = aws_instance.nat_instance.id
}

resource "aws_key_pair" "public_SSH_key" {
  key_name   = "key-for-ec2-connection"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}