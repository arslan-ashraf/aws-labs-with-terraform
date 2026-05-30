This lab is incomplete and creates at least 38 resources which take 5-10 minutes to create.  There is an EC2 in one VPC and an SQS interface endpoint in another VPC.  The VPCs are connected through VPC peering.  The goal of this lab is to SSH into the EC2 instance and from there send a message to the SQS queue over the private AWS network where a public DNS hostname like sqs.us-east-1.amazonaws.com resolves to the private IP address of the SQS endpoint.

How the DNS resolution flow works: 
1 - EC2 instance (or for example, a container) in VPC A attempts to connect to SQS and requests the DNS resolution for sqs.us-east-1.amazonaws.com

2 - Rule Match: The Route 53 Outbound Resolver inside VPC A evaluates the query, notices it matches the domain_name filter in aws_route53_resolver_rule

3 - Outbound Hop: VPC A's Outbound Route53 Endpoint then FORWARDs the query to target_ip in aws_route53_resolver_rule, which is the IP address of the Route53 Inbound Resolver Endpoint in VPC B where the SQS interface endpoint is

4 - Inbound Hop: The Route53 Inbound Resolver Endpoint inside the Target VPC receives the query, evaluates it against the local VPC network environment, and discovers the SQS VPC Interface Endpoint IP address

5 - Success: The private SQS endpoint IP is passed back across 
the network to the resource in VPC A, keeping all traffic entirely off the public internet