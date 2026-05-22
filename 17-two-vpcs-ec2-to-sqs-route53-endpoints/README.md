This lab is incomplete and creates at least 38 resources which take 5-10 minutes to create.  There is an EC2 in one VPC and an SQS interface endpoint in another VPC.  The VPCs 

How the DNS resolution flow works: 
1 - A container or EC2 instance in VPC A attempts to connect to SQS and 
requests the DNS resolution for sqs.us-east-1.amazonaws.com

2 - Rule Match: The Route 53 Resolver inside VPC A evaluates the query, 
notices it matches the domain_name filter in your aws_route53_resolver_rule, 
and intercepts it

3 - Outbound Hop: VPC A's Outbound Endpoint picks up the query 
and FORWARDs it to target_ip in aws_route53_resolver_rule

4 - Inbound Hop: The Inbound Endpoint inside the Target VPC receives the query 
via the network bridge, evaluates it against the local VPC network environment, 
and discovers the SQS VPC Interface Endpoint IP address

5 - Success: The private SQS endpoint IP is passed back across 
the network to the resource in VPC A, keeping all traffic entirely off the public 
internet