# aws_autoscaling_policy defines the rules and conditions for when
# and how an aws_autoscaling_group (ASG) should dynamically resize
# itself, while the ASG defines the (what) minimum, maximum, and
# desired capacity, the aws_autoscaling_policy determines when and
# how to add or remove instances within those limits based on 
# real-time metrics or schedules

resource "aws_autoscaling_policy" "ASG_cpu_target_tracking_policy" {
  name                   = "ASG_cpu_target_tracking_policy"
  autoscaling_group_name = aws_autoscaling_group.ec2_autoscaling_group.name
  policy_type            = "TargetTrackingScaling"

  # time in (seconds) AWS waits to start recording an instance's 
  # metrics, instance's metric data won't enter into the fleet's
  # average calculation until it has been active for at least
  # the estimated_instance_warmup time, used to prevent autoscaling
  # from kicking off during instance startup
  estimated_instance_warmup = 300   # seconds

  # simple config with predefined metric
  target_tracking_configuration {
    # trigger when average CPU utilization of the desired capacity
    # reaches 50%
    target_value = 50.0

    # tet to true if you ONLY want to add (scale out) instance and
    # never remove (scale in)
    disable_scale_in          = false 

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

  }

  # alternative custom config involving SQS queue and EC2 instances
  # target_tracking_configuration {

  #   target_value = 100

  #   customized_metric_specification {
  #     metrics {
  #       label = "Get the queue size (the number of messages waiting to be processed)"
  #       id    = "metric_1"
  #       metric_stat {
  #         metric {
  #           namespace   = "AWS/SQS"
  #           metric_name = "ApproximateNumberOfMessagesVisible"
  #           dimensions {
  #             name  = "QueueName"
  #             value = "<sqs_queue_name>"
  #           }
  #         }
  #         stat   = "Sum"
  #         period = 10
  #       }
  #       return_data = false
  #     }
  #     metrics {
  #       label = "Get the group size (the number of InService instances)"
  #       id    = "metric_2"
  #       metric_stat {
  #         metric {
  #           namespace   = "AWS/AutoScaling"
  #           metric_name = "GroupInServiceInstances"
  #           dimensions {
  #             name  = "AutoScalingGroupName"
  #             value = "<autoscaling_group_name>"
  #           }
  #         }
  #         stat   = "Average"
  #         period = 10
  #       }
  #       return_data = false
  #     }
  #     metrics {
  #       label       = "Calculate the backlog per instance"
  #       id          = "e1"
  #       expression  = "metric_1 / metric_2"
  #       return_data = true
  #     }
  #   }
  # }
}