# aws_autoscaling_policy defines the rules and conditions for when
# and how an aws_autoscaling_group (ASG) should dynamically resize
# itself, while the ASG defines the (what) minimum, maximum, and
# desired capacity, the aws_autoscaling_policy determines when and
# how to add or remove instances within those limits based on 
# real-time metrics or schedules

resource "aws_autoscaling_policy" "ASG_cpu_target_tracking_policy" {
  name                   = "cpu-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.ec2_autoscaling_group.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    # trigger when average CPU utilization of the desired capacity
    # reaches 50%
    target_value = 50.0
  }
}
