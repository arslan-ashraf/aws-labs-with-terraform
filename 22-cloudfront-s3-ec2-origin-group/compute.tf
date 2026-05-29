resource "aws_instance" "web_server" {
  ami                         = "ami-0ec10929233384c7f"
  region                      = "us-east-1"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_for_ec2.id
  user_data                   = file("${path.module}/userdata.sh")
  key_name                    = "key-for-ec2-connection"

  vpc_security_group_ids = [
    aws_security_group.security_group_for_ec2_instance.id
  ]

  tags = { Name = "web_server_ubuntu_ami" }

}

resource "aws_key_pair" "deployer" {
  key_name   = "key-for-ec2-connection"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}

# allocate a Static Elastic IP, this is done so that CloudFront always
# has a fixed domain name to point to, the problem is that every time an 
# EC2 instance is stopped and restarted, AWS destroys its old public DNS name
# and generates a new one, if your server reboots, CloudFront will break 
# because it will keep routing traffic to an expired domain name

resource "aws_eip" "eip_for_cloudfront_distribution" {
  instance = aws_instance.web_server.id
  domain   = "vpc"
}