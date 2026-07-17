This lab creates a VPC instance connect endpoint, 
**aws_ec2_instance_connect_endpoint** which takes over 5 minutes to create.

We create an EC2 instance in a private subnet and SSH into it using EC2 Instance Direct Connect in the AWS console.  No internet gateway, route tables, and no SSH keys required.

We also create a NAT Gateway in a public subnet and SSH into the EC2 instance and verify that the instance has internet connectivity through the NAT Gateway.

To verify that indeed the EC2 instance is connecting to the web through the NAT Gateway, SSH into the EC2 instance and run the following command:

```
curl ifconfig.me
```

It will return an IP address that should match the Elastic IP that AWS assigned to the NAT Gateway.