This lab creates and EC2 instance, an SNS topic and a CloudWatch alarm to notify us via email that a metric has been breached.

Note: AWS monitors various metrics including the CPU metric automatically for EC2 instances and sends them to CloudWatch Metrics. It is not necessary to install an agent on the EC2 instance just to get CPU metrics.

However, EC2 CPU utilization is not automatically written to a CloudWatch Log Group. If you want CPU utilization values to appear in a log group, you must run the CloudWatch Agent on the instance and configure it to collect CPU metrics and publish them. The agent can publish metrics to CloudWatch Metrics and optionally write agent logs to CloudWatch Logs.  We do not implement that in this lab.


We first SSH into the EC2 instance, create and launch a Python script inside the instance to spike its CPU usage.  We can then see that metric in CloudWatch.

To connect to an ec2 using ssh using the private key:

Note: -i is for "identity"
```
ssh -i .ssh/key-for-ec2-connection <remote_username>@<remote_ip_address>
```