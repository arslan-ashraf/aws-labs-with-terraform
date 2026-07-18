This lab creates a VPC instance connect endpoint, 
**aws_ec2_instance_connect_endpoint** which takes over 5 minutes to create.

This is a continuation of the previous lab but instead of creating an AWS managed NAT Gateway, we run our own by using an EC2 instance in a public subnet to operate as a NAT Instance.

We create a private EC2 instance in a private subnet and SSH into it using EC2 Instance Direct Connect in the AWS console.  No internet gateway, route tables, and no SSH keys required.

To verify that indeed the private EC2 instance is connecting to the web through the NAT Instance, SSH into the private EC2 instance and run the following command:

```
curl ifconfig.me
```

It will return an IP address that should match the public IP that AWS assigned to the NAT Instance.

To see the NAT happening, SSH into the NAT instance and run:
```sudo tcpdump -ni any icmp```

and then SSH into the private EC2 instance and run:
```ping google.com```

On the NAT instance, this should start showing packets coming to the NAT instance from the private instance and out to the internet.  The result should be something like this for a single ICMP packet:

```
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes

03:05:53.815480 enX0  In  IP 10.0.7.11 > 64.233.180.100: ICMP echo request, id 1467, seq 1, length 64
03:05:53.815512 enX0  Out IP 10.0.5.14 > 64.233.180.100: ICMP echo request, id 1467, seq 1, length 64
03:05:53.818562 enX0  In  IP 64.233.180.100 > 10.0.5.14: ICMP echo reply, id 1467, seq 1, length 64
03:05:53.818572 enX0  Out IP 64.233.180.100 > 10.0.7.11: ICMP echo reply, id 1467, seq 1, length 64
```

The first line is a packet coming in from IP 10.0.7.11 (private instance) to google.com.
The second line is a packet going out from IP 10.0.5.14 (NAT instance) to google.com.  This is the NAT happening.
The third and fourth lines are the return packets.

The following are some of the concerns with running an EC2 instance as a NAT Instance:

- No Native High Availability

- Bandwidth Cap: Network throughput is limited by the network performance capabilities of the EC2 instance type.

- Manual Upkeep: OS software updates, security patches, scaling.