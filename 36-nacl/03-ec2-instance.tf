resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0ec10929233384c7f"
  region                      = "us-east-1"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_in_example_vpc.id
  key_name                    = aws.aws_key_pair.public_private_key_pair.key_name

  vpc_security_group_ids = [
    aws_security_group.security_group_public_traffic.id
  ]

  tags = { Name = "ubuntu-ami" }

}

resource "aws_key_pair" "public_private_key_pair" {
  key_name   = "key-for-ec2-connection"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}