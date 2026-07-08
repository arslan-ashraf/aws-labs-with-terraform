resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name_prefix         = "ec2_autoscaling_group"
  # desired_capacity    = 1 # remove when using autoscaling policy
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

  # wait 5 minutes before allowing another scaling activity
  # prevents excessive autoscaled instances from spinning up
  default_cooldown = 300

  # scale-in protection for new instances
  # set to true only if ALL new instances must be permanently 
  # protected from scaling down
  protect_from_scale_in = false 

  lifecycle {
    create_before_destroy = true
  }

  tag {
    Name = "Auto-Scaling-Group-Managed-Instance"
  }
}