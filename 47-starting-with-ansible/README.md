This lab creates one EC2 instance in a private subnet and another one in a public subnet all using loops.  Furthermore, security groups are attached to each EC2 instance to allow remote SSH login to the instance in the public subnet, which also has a rule to send out ECHO ICMP messages using PING to the internet.

The instance in the private subnet can only be accessed by other instances in the same VPC through PING and SSH.

We add a `user_data.sh` script to the public EC2 instance which builds two Docker images, one for a basic Python application and the other 

1. Run the Terraform lab.

2. SSH into the EC2 instance in the public subnet and ping the EC2 instance in the private subnet using its private IP address.