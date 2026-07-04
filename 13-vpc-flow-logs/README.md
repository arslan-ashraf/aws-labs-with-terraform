In this lab, we want to capture network traffic coming into and out of our example VPC and send that traffic to a CloudWatch log group.  

To do that we create a Cloudwatch log group, and an IAM role for the VPC Flow Logs AWS resource that will have permissions to create a log stream, write to it, and describe it as well.  We also have an EC2 instance in a public subnet.

We SSH into the instance and ping out to any website and this will log the traffic flow every 60 seconds.  We can check the CloudWatch logs to see the traffic captured.

1. Run Terraform.

2. SSH into the EC2 instance and ping and website.

3. Check CloudWatch logs to see the ping recorded.