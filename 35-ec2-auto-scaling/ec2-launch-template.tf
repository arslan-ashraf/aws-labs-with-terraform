resource "aws_launch_template" "ec2_auto_scaling_launch_template" {
  name = "ec2_auto_scaling_launch_template"
  # block_device_mappings = {}  # EBS volumes to attach

  # iam_instance_profile = ""
  image_id = "Required"
  instance_initiated_shutdown_behavior = "Required"
  instance_market_options = "Required"
  instance_type = "Required"
  kernel_id = "Required"
  key_name = "Required"
  license_specification = "Required"
  monitoring = "Required"
  network_interfaces = "Required"
  placement = "Required"
  ram_disk_id = "Required"
  security_group_names = "Required"
  vpc_security_group_ids = "Required"
  tag_specifications = "Required"
  tags = "Optional"
}