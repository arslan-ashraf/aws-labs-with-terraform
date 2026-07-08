# aws_autoscaling_policy defines the rules and conditions for when
# and how an aws_auto_scaling_group (ASG) should dynamically resize
# itself, while the ASG defines the (what) minimum, maximum, and
# desired capacity, the aws_auto_scaling_policy determines when and
# how to add or remove instances within those limits based on 
# real-time metrics or schedules