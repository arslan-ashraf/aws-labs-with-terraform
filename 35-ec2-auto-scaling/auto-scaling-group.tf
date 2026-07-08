resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name_prefix         = "ec2_autoscaling_group"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1

  # where the EC2 instances will be launched, pass in only one subnet
  # if single AZ low latency is required, e.g. database nodes
  # and set aws_placement_group strategy = "cluster"
  vpc_zone_identifier = [
    aws_subnet.public_subnet_1_for_ec2.id, 
    aws_subnet.public_subnet_2_for_ec2.id
  ]

  placement_group = aws_placement_group.ec2_autoscaling_placement_group.id

  launch_template {
    id      = aws_launch_template.ec2_auto_scaling_launch_template.id
    version = "$Latest" # use the newest version of the template
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    Name = "Auto-Scaling-Group-Managed-Instance"
  }
}