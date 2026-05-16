This lab creates a VPC instance connect endpoint, 
**aws_ec2_instance_connect_endpoint** which takes over 5 minutes to create.

We create an EC2 instance in a private subnet and SSH into it using EC2 Instance Direct Connect in the AWS console.  No internet gateway and no SSH keys required.  

We also create a VPC Gateway Endpoint which is free of charge to enable private connectivity from the EC2 intance to S3.  However, setting up the connectivity requires care.

The security group rules, EC2 direct connect endpoint needs to have an outbound SSH rule while the EC2 instance needs to have an inbound SSH rule with correct source and destinations.  Further, the EC2 instance needs to have an outbound rule to connect to S3 using the gateway endpoint.

The E2 instance needs IAM permissions to access S3 **and** S3 gateway endpoint needs to allow permissions to access S3 as well.  Do note that S3 permissions are specific to just the one bucket that's created so S3 global commands list
**aws s3 ls** won't work.