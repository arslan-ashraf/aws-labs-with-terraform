# this file has three security groups, one for the ec2 instance, one for ec2 
# direct connect endpoint, and one for vpc interface endpoint


########################################################################
##################### EC2 SECURITY GROUP & RULE ########################
########################################################################

resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance" }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic coming from
  referenced_security_group_id = aws_security_group.security_group_for_ec2_instance_endpoint.id

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

# egress rule so EC2 instance can access S3 using the gateway endpoint
resource "aws_vpc_security_group_egress_rule" "allow_egress_https_to_s3" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id
  description       = "Allow outbound HTTPS traffic to S3 Gateway Endpoint"

  # Target the automatically managed AWS S3 IP ranges
  prefix_list_id = aws_vpc_endpoint.s3_gateway.prefix_list_id

  # Configure protocol and port for HTTPS
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  tags = {
    Name = "egress-s3-https"
  }
}


resource "aws_security_group" "security_group_for_ec2_instance_endpoint" {
  name   = "security_group_for_ec2_instance_endpoint"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance_endpoint" }
}

resource "aws_vpc_security_group_egress_rule" "egress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance_endpoint.id

  # Target destination
  referenced_security_group_id = aws_security_group.security_group_for_ec2_instance.id

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}


resource "aws_security_group" "security_group_for_ec2_instance_endpoint" {
  name   = "security_group_for_ec2_instance_endpoint"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance_endpoint" }
}