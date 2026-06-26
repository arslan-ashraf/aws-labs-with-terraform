This is the same lab as lab 17 and is complete.  It creates 29 resources which take about 5 minutes to create.  There is an EC2 in one VPC and an SQS interface endpoint in another VPC.  The VPCs are connected through VPC peering.  The goal of this lab is to SSH into the EC2 instance and from there send a message to the SQS queue over the private AWS network where a public DNS hostname like sqs.us-east-1.amazonaws.com resolves to a private IP address of the SQS endpoint.

The previous lab created two Route53 Endpoints each of which creates two ENI endpoints which are costly.  This lab does not do that.  Here, we disable private DNS inside the SQS `aws_vpc_endpoint` by setting `private_dns_enabled = false` and instead of AWS creating a hidden private hosted zone that we can't manage, we create one ourselves and associate it with the VPC with the EC2 instance in it.

Use the command below to verify that EC2 is able to connect to SQS using interface endpoint:

```
aws sqs send-message --queue-url https://sqs.us-east-1.amazonaws.com/<aws_account_id>/simple_queue --message-body "test message 1"  --region us-east-1
```