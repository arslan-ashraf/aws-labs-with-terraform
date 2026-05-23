#########################################################################
##################### EC2 SECURITY GROUP & RULES ########################
#########################################################################

resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance" }
}

# allow the load balancer make http requests the EC2 instance
resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic coming from
  referenced_security_group_id = aws_security_group.security_group_for_application_load_balancer.id

  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"
}


########################################################################
################# LOAD BALANCER SECURITY GROUP & RULES #################
########################################################################


resource "aws_security_group" "security_group_for_application_load_balancer" {
  name   = "security_group_for_application_load_balancer"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_application_load_balancer" }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_all_public_traffic_rule" {
  security_group_id = aws_security_group.security_group_for_application_load_balancer.id

  # where is the traffic coming from
  cidr_ipv4 = "0.0.0.0/0"

  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"
}