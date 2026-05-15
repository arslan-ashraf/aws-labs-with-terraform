resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0ec10929233384c7f"
  region                      = "us-east-1"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.private_subnet_for_ec2_instance.id
  key_name                    = "key-for-ec2-connection"

  vpc_security_group_ids = [
    aws_security_group.security_group_for_ec2_instance.id
  ]

  tags = { Name = "ubuntu-ami" }

}