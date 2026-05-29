This lab creates one EC2 instance in a VPC in the US-east-1 region and another one in a different VPC in the Tokyo ap-northeast-1 region.  The goal is to get each instance to be able to PING the other one.

To ping from one instance to another, log in to one of them through SSH using its public IP address.  Once in, ping the other instance using that instance's private IP address.

This lab creates 24 resources.