resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0236922087fa98b6e"
  region                      = "us-east-1"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_for_ec2_instance.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  # user_data                   = file("${path.module}/userdata.sh")
  key_name                    = "key-for-ec2-connection"

  vpc_security_group_ids = [
    aws_security_group.security_group_for_ec2_instance.id
  ]

  tags = { Name = "amazon-linux-ami" }

}

resource "aws_key_pair" "deployer" {
  key_name   = "key-for-ec2-connection"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}