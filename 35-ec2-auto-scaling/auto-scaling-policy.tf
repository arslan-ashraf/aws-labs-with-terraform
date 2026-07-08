# aws_autoscaling_policy defines the rules and conditions for when
# and how an aws_auto_scaling_group (ASG) should dynamically resize
# itself, while the ASG defines the (what) minimum, maximum, and
# desired capacity, the aws_auto_scaling_policy determines when and
# how to add or remove instances within those limits based on 
# real-time metrics or schedules

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "cpu-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0 # Target 50% CPU utilization
  }
}
