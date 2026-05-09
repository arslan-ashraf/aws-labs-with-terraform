#################################################################################
########################## US-East-1 Region - EC2 ###############################
#################################################################################

data "aws_ami" "debian_ami" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name = "name" # the AMI name field in AWS
    # to find the string inside the values array, use:
    # aws ec2 describe-images --region us-east-1 --image-ids ami-0b75f821522bcff85
    values = ["debian-13-amd64-20260316-2418"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]

  }

}

resource "aws_instance" "ec2_instances_US_east" {
  region                      = "us-east-1"
  availability_zone           = "us-east-1a"
  ami                         = data.aws_ami.debian_ami.id
  instance_type               = "t2.nano"
  subnet_id                   = aws_subnet.subnet_in_US_east.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.security_group_US_east.id
  ]

  tags = { Name = "debian-machine-in-US-east" }

  # if the ami gets updated by the time the next apply happens, Terraform
  # might delete the previous instance and replace it with the latest ami
  # to prevent that:
  lifecycle {
    ignore_changes = [ami]
  }
}


#################################################################################
############################ Tokyo Region - EC2 #################################
#################################################################################

data "aws_ami" "ubuntu_ami" {
  most_recent = true

  # Canonical's account ID, ensures the image is from Canonical and not
  # community or elsewhere
  owners = ["099720109477"]

  filter {
    name = "name" # the AMI name field in AWS
    # to find the string inside the values array, use:
    # aws ec2 describe-images --region us-east-1 --image-ids ami-0ec10929233384c7f
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260313"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]

  }

}

resource "aws_instance" "ec2_instances_Tokyo" {
  region                      = "ap-northeast-1"
  availability_zone           = "apne1-az1"
  ami                         = data.aws_ami.ubuntu_ami.id
  instance_type               = "t2.nano"
  subnet_id                   = aws_subnet.subnet_in_Tokyo.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.security_group_Tokyo.id
  ]

  tags = { Name = "ubuntu-machine-in-Tokyo" }

  # if the ami gets updated by the time the next apply happens, Terraform
  # might delete the previous instance and replace it with the latest ami
  # to prevent that:
  lifecycle {
    ignore_changes = [ami]
  }
}