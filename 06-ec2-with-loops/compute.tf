data "aws_ami" "ubuntu_ami" {
  most_recent = true

  # Canonical's account ID, ensures the image is from Canonical and not
  # community or elsewhere
  owners      = ["099720109477"]

  filter {
    name = "name"      # the AMI name field in AWS
    # to find the string inside the values array, use:
    # aws ec2 describe-images --region us-east-1 --image-ids ami-0ec10929233384c7f
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260313"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]

  }

}

data "aws_ami" "debian_ami" {
  most_recent = true
  owners = ["136693071363"]

  filter {
    name = "name"      # the AMI name field in AWS
    # to find the string inside the values array, use:
    # aws ec2 describe-images --region us-east-1 --image-ids ami-0b75f821522bcff85
    values = ["debian-13-amd64-20260316-2418"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]

  }

}


locals {
  ami_ids = {
    ubuntu = data.aws_ami.ubuntu_ami.id
    debian = data.aws_ami.debian_ami.id
  }
}

resource "aws_instance" "create_instances_from_map" {
  for_each = var.ec2_instance_config_map

  # local.ami_ids map holds dynamically fetched ami ids and each.value.ami
  # provides the keys to look into the local.ami_ids maps
  ami = local.ami_ids[each.value.ami]

  instance_type = each.value.instance_type
  subnet_id = aws_subnet.subnets_in_example_vpc[each.value.subnet_name].id
  availability_zone = "us-east-1a"
  associate_public_ip_address = false
  
  tags = {
    Name = "${each.value.ami}-machine"
  }

  # if the ami gets updated by the time the next apply happens, Terraform
  # might delete the previous instance and replace it with the latest ami
  # to prevent that:
  lifecycle {
    ignore_changes = [ami]
  }
}


############### NOT USED ################
# for illustrative purposes as var.ec2_instance_config_list = []
# so length(var.ec2_instance_config_list) = 0
# Terraform reads it, but doesn't do anything

resource "aws_instance" "create_instances_from_list" {
  count = length(var.ec2_instance_config_list)

  ami = local.ami_ids[var.ec2_instance_config_list[count.index].ami]

  instance_type = var.ec2_instance_config_list[count.index].instance_type

  subnet_id = aws_subnet.subnets_in_example_vpc[
    var.ec2_instance_config_list[count.index].subnet_name
  ].id

  availability_zone = "us-east-1a"
  associate_public_ip_address = false
  
  tags = {
    Name = "${var.ec2_instance_config_list[count.index].ami}-machine"
  }

  # if the ami gets updated by the time the next apply happens, Terraform
  # might delete the previous instance and replace it with the latest ami
  # to prevent that:
  lifecycle {
    ignore_changes = [ami]
  }
}