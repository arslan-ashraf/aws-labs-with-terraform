module "vpc_network_module" {
  source = "./module"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "EKS_WORKER_NODES_VPC" # tag name
  }

  subnet_config = {
    # subnets a and b are private for hosting EKS worker nodes
    private_subnet_a = {
      cidr_block = "10.0.1.0/24"
      public     = false
      AZ         = "us-east-1a"
    }
    private_subnet_b = {
      cidr_block = "10.0.2.0/24"
      public     = false
      AZ         = "us-east-1b"
    }

    # subnet c is public, it is for hosting public facing resources
    # such as Load Balancers and NAT Gateways/Instances
    public_subnet_c = {
      cidr_block             = "10.0.10.0/24"
      AZ                     = "us-east-1a"
      public                 = true
      contains_NAT_instance  = true
    }

  }

  NAT_instance_config = {
    instance_type = "t2.nano"
  }
}





resource "aws_subnet" "private_subnet_for_private_ec2_instance" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.7.0/24"
  vpc_id            = module.vpc_network_module.vpc_id

  tags = { Name = "private_subnet_for_private_ec2_instance" }
}

resource "aws_route_table" "route_table_for_private_subnet" {
  vpc_id = module.vpc_network_module.vpc_id

  route {
    # destination
    cidr_block = "0.0.0.0/0"

    # target to reach destintion
    network_interface_id = module.vpc_network_module.NAT_instance_network_interface_id
  }

  tags = { Name = "route_table_for_private_subnet" }

}

resource "aws_route_table_association" "route_table_association_private_subnet_example_vpc" {
  subnet_id      = aws_subnet.private_subnet_for_private_ec2_instance.id
  route_table_id = aws_route_table.route_table_for_private_subnet.id
}


resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = module.vpc_network_module.vpc_id
  tags   = { Name = "security_group_for_ec2_instance" }
}


# allow SSH traffic in from the EC2 instance connect endpoint
resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic coming from
  referenced_security_group_id = aws_security_group.security_group_for_ec2_instance_endpoint.id

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

# allow traffic out to the NAT gateway
resource "aws_vpc_security_group_egress_rule" "egress_nat_gateway_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # Target destination
  cidr_ipv4 = "0.0.0.0/0"

  # all protocols
  ip_protocol = "-1"
}


resource "aws_vpc_security_group_ingress_rule" "ingress_from_NAT_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic coming from
  cidr_ipv4 = "10.0.0.0/16"

  ip_protocol = "-1"
}






resource "aws_subnet" "private_subnet_for_private_ec2_instance_endpoint" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.6.0/24"
  vpc_id            = module.vpc_network_module.vpc_id

  tags = { Name = "private_subnet_for_private_ec2_instance_endpoint" }
}

resource "aws_security_group" "security_group_for_ec2_instance_endpoint" {
  name   = "security_group_for_ec2_instance_endpoint"
  vpc_id = module.vpc_network_module.vpc_id
  tags   = { Name = "security_group_for_ec2_instance_endpoint" }
}

# send SSH traffic out to the EC2 instance
resource "aws_vpc_security_group_egress_rule" "egress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance_endpoint.id

  # Target destination
  referenced_security_group_id = aws_security_group.security_group_for_ec2_instance.id

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

resource "aws_ec2_instance_connect_endpoint" "instance_connect_endpoint" {
  subnet_id          = aws_subnet.private_subnet_for_private_ec2_instance_endpoint.id
  security_group_ids = [aws_security_group.security_group_for_ec2_instance_endpoint.id]

  tags = { Name = "instance_connect_endpoint" }
}

