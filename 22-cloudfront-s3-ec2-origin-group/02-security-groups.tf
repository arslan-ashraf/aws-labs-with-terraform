#########################################################################
##################### EC2 SECURITY GROUP & RULES ########################
#########################################################################

resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance" }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_all_public_traffic_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic coming from
  cidr_ipv4 = "0.0.0.0/0"

  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"
}

# fetch CloudFront's official live IP ranges for AWS region
# Terraform detects the region automatically, but if a different region
# is needed, add new provider and alias, then add provider = aws.alias
# data "aws_ec2_managed_prefix_list" "cloudfront" {
#   name = "com.amazonaws.global.cloudfront.origin-facing"
# }

# resource "aws_vpc_security_group_ingress_rule" "ingress_from_cloudfront_only_rule" {
#   from_port       = 80
#   to_port         = 80
#   protocol        = "tcp"
#   # Opens to CloudFront only
#   prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
# }

resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic coming from
  cidr_ipv4 = "0.0.0.0/0"

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress_to_internet_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic going
  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}