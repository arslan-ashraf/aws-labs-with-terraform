resource "aws_instance" "web_server_1" {
  ami                         = "ami-0ec10929233384c7f"
  region                      = "us-east-1"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_1_for_ec2.id
  user_data                   = file("${path.module}/userdata.sh")

  vpc_security_group_ids = [
    aws_security_group.security_group_for_ec2_instance.id
  ]

  tags = { Name = "ubuntu-ami" }

}

resource "aws_instance" "web_server_2" {
  ami                         = "ami-0ec10929233384c7f"
  region                      = "us-east-1"
  availability_zone           = "us-east-1b"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_2_for_ec2.id
  user_data                   = file("${path.module}/userdata.sh")

  vpc_security_group_ids = [
    aws_security_group.security_group_for_ec2_instance.id
  ]

  tags = { Name = "ubuntu-ami" }

}