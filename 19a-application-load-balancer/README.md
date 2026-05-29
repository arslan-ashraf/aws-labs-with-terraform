This lab creates two EC2 instances and an Application Load Balancer all in the same VPC but all in different subnets.  The EC2 instances have outbound internet connectivity only to allow the Apache Web Server to to be installed.

To see the load balancing in action, visit the public URL of the load balancer and refresh the page to see the round-robin load balancing.