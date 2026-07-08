resource "aws_launch_template" "ec2_auto_scaling_launch_template" {
  name = "ec2_auto_scaling_launch_template"

  image_id = "ami-0ec10929233384c7f"  # ubuntu ami
  instance_type = "t2.nano"
  key_name      = "key-for-ec2-connection"

  placement {
    availability_zone = "us-west-2a"
  }

  vpc_security_group_ids = [""]

  # iam_instance_profile = ""

  # block_device_mappings = {}  # EBS volumes to attach
  # instance_initiated_shutdown_behavior = "stop"  # default "stop"
  # monitoring = ""

}

resource "aws_key_pair" "deployer" {
  key_name   = "key-for-ec2-connection"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}