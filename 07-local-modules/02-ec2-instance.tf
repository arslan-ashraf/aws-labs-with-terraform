data "aws_ami" "ubuntu_ami" {
  most_recent = false

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

resource "aws_instance" "example_ec2_instance" {
  ami = data.aws_ami.ubuntu_ami.id
  instance_type = "t2.nano"
  subnet_id = module.vpc_and_subnets_module.private_subnets["subnet_b"].subnet_id
  tags = { Name = "example_ec2_instance" }
}