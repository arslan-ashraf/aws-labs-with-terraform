This lab creates a VPC endpoint, ** bold aws_ec2_instance_connect_endpoint** which takes over 5 minutes to create.

We create an EC2 instance in a private subnet and SSH into it using EC2 Instance Direct Connect in the AWS console.  No internet gateway, route tables, and SSH keys required.  

However, setting up the connectivity requires care.  Check the security group rules.  Direct connect endpoint needs to have an outbound SSH rule while the EC2 instance needs to have an inbound SSH rule with correct source and destinations.