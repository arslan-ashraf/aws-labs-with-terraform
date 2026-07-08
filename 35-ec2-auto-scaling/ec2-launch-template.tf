resource "aws_launch_template" "ec2_auto_scaling_launch_template" {
  name = "ec2_auto_scaling_launch_template"

  image_id = "ami-0ec10929233384c7f"  # ubuntu ami
  instance_type = "t2.nano"
  key_name      = "key-for-ec2-connection"

  vpc_security_group_ids = [aws_security_group.security_group_public_traffic.id]

  user_data = file("${path.module}/user_data.sh")

  placement {
    availability_zone = "us-west-2a"
  }

  # iam_instance_profile = ""

  # ebs_optimized = true
  # instance_initiated_shutdown_behavior = "stop"  # default "stop"
  # monitoring = ""

  # default_version = 1
  # update_default_version = true
  
  # EBS volumes to attach
  block_device_mappings = {
    device_name = "/dev/sda1"
    
  }  


}

resource "aws_key_pair" "deployer" {
  key_name   = "key-for-ec2-connection"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}