In this lab, we want to capture network traffic coming into and out of our example VPC and send that traffic to a CloudWatch log group.  

To do that we create a Cloudwatch log group, and an IAM role for the VPC Flow Logs AWS resource that will have permissions to create a log stream, write to it, describe it as well as an EC2 instance in a public subnet.

We SSH into the instance and ping out to any website and check the CloudWatch logs to see the traffic captured.