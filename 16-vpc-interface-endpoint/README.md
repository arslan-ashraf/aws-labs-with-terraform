This lab creates a VPC instance connect endpoint, 
**aws_ec2_instance_connect_endpoint** which takes over 5 minutes to create.

We create an EC2 instance in a private subnet and SSH into it using EC2 Instance Direct Connect in the AWS console.  No internet gateway and no SSH keys required.  

We also create a VPC Interface Endpoint to enable private connectivity from the EC2 intance to SQS.  However, setting up the connectivity requires care.

The security group rules, EC2 direct connect endpoint needs to have an outbound SSH rule while the EC2 instance needs to have an inbound SSH rule with correct source and destinations.  Further, the EC2 instance needs to have an outbound rule to connect to SQS using the interface endpoint.

The E2 instance needs IAM permissions to access SQS **and** SQS interface endpoint needs to allow permissions to access SQS as well.

Once you have SSH'd into the instance run the commands below.

Use the command below to verify that private DNS is available:
```
nslookup sqs.us-east-1.amazonaws.com
```

Use the command below to verify that EC2 is able to connect to SQS using interface endpoint:
```
aws sqs send-message --queue-url https://sqs.us-east-1.amazonaws.com/<aws_account_id>/simple_queue --message-body "test message 1"  --region us-east-1
```