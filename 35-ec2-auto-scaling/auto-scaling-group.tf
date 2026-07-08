resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name_prefix         = "ec2_autoscaling_group"
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = ["subnet-12345678", "subnet-87654321"]

  # Attach instances to your physical hardware placement group
  placement_group = aws_placement_group.app_placement.id

  # Link the launch template configuration
  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest" # Automatically uses the newest version of the template
  }

  # Enforce structural updates over raw replacements
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "ASG-Managed-Instance"
    propagate_at_launch = true
  }
}