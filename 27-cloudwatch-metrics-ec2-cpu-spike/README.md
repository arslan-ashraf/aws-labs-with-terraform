This lab creates and EC2 instance and a CloudWatch Group that logs CPU usage.  We first SSH into the EC2 instance, create and launch a Python script inside the instance to spike its CPU usage.  We then see that metric in CloudWatch.

To connect to an ec2 using ssh using the private key:

Note: -i is for "identity"
```
ssh -i .ssh/key-for-ec2-connection <remote_username>@<remote_ip_address>
```