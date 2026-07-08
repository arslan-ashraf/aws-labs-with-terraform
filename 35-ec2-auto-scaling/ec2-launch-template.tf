resource "aws_key_pair" "deployer" {
  key_name   = "key-for-ec2-connection"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}

resource "aws_launch_template" "ec2_auto_scaling_launch_template" {
  name = "ec2_auto_scaling_launch_template"

  image_id = "ami-0ec10929233384c7f"  # ubuntu ami
  instance_type = "t2.nano"
  key_name      = "key-for-ec2-connection"

  vpc_security_group_ids = [aws_security_group.security_group_public_traffic.id]

  user_data = file("${path.module}/user_data.sh")

  placement {
    # availability_zone = "us-east-1a" # conflicts with load balancer config

    # tenancy defines the hardware isolation level, options include:
    # default - shared physical hardware
    # dedicated - single-tenant hardware dedicated to your AWS account
    # host - runs on a specific, fully-managed dedicated host
    tenancy           = "dedicated"

    group_name        = aws_placement_group.ec2_autoscaling_placement_group.name
    # partition_number  = 1
    # topology_type     = ""
  }

  # monitoring {} determines the frequency of CloudWatch metrics collection

  # enabled = true activates detailed monitoring, metrics are collected
  # every 1 minute, extra charges, better for auto scaling and quick
  # reaction, enables auto scaling policy to trigger in a minute

  # enabled = false if the default standard monitoring, metrics are 
  # collected every 5 minutes

  monitoring = {
    enabled = true
  }

  # iam_instance_profile = ""

  # ebs_optimized = true
  # instance_initiated_shutdown_behavior = "stop"  # default "stop"

  # default_version = 1
  # update_default_version = true
  
  # EBS volumes to attach
  # block_device_mappings {
  #   device_name = "/dev/xvda" # Common root device name for Linux AMIs

  #   ebs {
  #     volume_size           = 10      # Gigabytes
  #     volume_type           = "gp3"
  #     iops                  = 1000
  #     throughput            = 25      # MiB/s, only for gp3 volumes
  #     encrypted             = true
  #     delete_on_termination = true
  #   }
  # }

  # # additional EBS volume
  # block_device_mappings {
  #   device_name = "/dev/sdb"

  #   ebs {
  #     volume_size           = 10      # Gigabytes
  #     volume_type           = "gp3"
  #     encrypted             = true
  #     delete_on_termination = true
  #   }
  # }


}