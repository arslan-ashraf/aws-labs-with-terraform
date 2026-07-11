resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name_prefix      = "ec2_autoscaling_group"
  desired_capacity = 1 # remove when using autoscaling policy without lifecycle {}
  max_size         = 2
  min_size         = 1

  health_check_type = "ELB" # or EC2

  # gives newly launched instances 120 seconds to initialize before
  # the ASG starts terminating them for failing those health checks
  health_check_grace_period = 120

  target_group_arns = [aws_lb_target_group.web_servers_target_group.arn]

  # where the EC2 instances will be launched, pass in only one subnet
  # if single AZ low latency is required, e.g. database nodes
  # and set aws_placement_group strategy = "cluster"
  vpc_zone_identifier = [
    aws_subnet.public_subnet_1_for_ec2.id,
    aws_subnet.public_subnet_2_for_ec2.id
  ]

  instance_refresh {

    # enforce zero down time 
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50 # keep at least 50% instances while updating others
    }
    triggers = ["tag"] # retriggers if tag is updated
  }

  placement_group = aws_placement_group.ec2_autoscaling_placement_group.id

  launch_template {
    id      = aws_launch_template.ec2_auto_scaling_launch_template.id
    version = "$Latest" # use the newest version of the template
  }

  # wait (in seconds) before allowing another scaling activity
  # prevents excessive autoscaling, instances from spinning down
  # and then possible back up again very quickly
  default_cooldown = 60 # matters little if at all with "TargetTrackingScaling" policy
  # AWS uses its own CloudWatch alarm set at 35% CPUUtilization for 15 minutes
  # before it scales back down

  # scale-in (removing instances) protection for new instances
  # set to true only if ALL new instances must be permanently 
  # protected from scaling down
  protect_from_scale_in = false

  lifecycle {
    create_before_destroy = true

    # allow autocaling to change desired_capacity without Terraform
    ignore_changes = [desired_capacity]
  }

}