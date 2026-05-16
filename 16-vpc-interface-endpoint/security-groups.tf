# this file has three security groups, one for the ec2 instance, one for ec2 
# direct connect endpoint, and one for vpc interface endpoint


#########################################################################
##################### EC2 SECURITY GROUP & RULES ########################
#########################################################################

resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance" }
}

# allow the instance connect endpoint to get into the EC2 instance
resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic coming from
  referenced_security_group_id = aws_security_group.security_group_for_ec2_instance_endpoint.id

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress_from_ec2_to_sqs_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic going
  referenced_security_group_id = aws_security_group.security_group_for_interface_endpoint.id

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"
}


########################################################################
################## EC2 ENDPOINT SECURITY GROUP & RULES #################
########################################################################


resource "aws_security_group" "security_group_for_ec2_instance_endpoint" {
  name   = "security_group_for_ec2_instance_endpoint"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance_endpoint" }
}

# create outbound connection to EC2 instance
resource "aws_vpc_security_group_egress_rule" "egress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance_endpoint.id

  # Target destination
  referenced_security_group_id = aws_security_group.security_group_for_ec2_instance.id

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}


########################################################################
############# VPC INTERFACE ENDPOINT SECURITY GROUP & RULES ############
########################################################################

resource "aws_security_group" "security_group_for_interface_endpoint" {
  name   = "security_group_for_interface_endpoint"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_interface_endpoint" }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_from_ec2_to_sqs_rule" {
  security_group_id = aws_security_group.security_group_for_interface_endpoint.id

  # where is the traffic coming from
  referenced_security_group_id = aws_security_group.security_group_for_ec2_instance.id

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"
}