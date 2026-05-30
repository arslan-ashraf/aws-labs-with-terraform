This lab creates two EC2 instances and an Application Load Balancer all in the same VPC but all in different subnets.  The EC2 instances have outbound internet connectivity only to allow the Apache Web Server to to be installed.

We also create Route53 Public DNS A records the point a custom domain to the load balancer.  Finally, we also generate an TLS Certificate using Amazon Certificate Manager (ACM).  This way, we can access the website of the custom domain using HTTPS, that hits the load balancer.

To see the load balancing in action, visit the custom domain name and refresh the page to see the round-robin load balancing.