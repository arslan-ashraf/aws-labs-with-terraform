This lab creates and EC2 instance and a CloudWatch Group that logs CPU usage.  We first SSH into the EC2 instance, create and launch a Python script inside the instance to spike its CPU usage.  We then see that metric in CloudWatch.

Note: AWS monitors various metrics including the CPU metric automatically for EC2 instances. It is not necessary to install an agent on the EC2 instance to get CPU metrics.

To connect to an ec2 using ssh using the private key:

Note: -i is for "identity"
```
ssh -i .ssh/key-for-ec2-connection <remote_username>@<remote_ip_address>
```