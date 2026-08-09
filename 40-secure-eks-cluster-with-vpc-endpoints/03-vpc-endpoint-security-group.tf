# security group shared by all VPC Interface Endpoints
resource "aws_security_group" "vpc_endpoints_sg" {
  name        = "vpc_endpoints_sg"
  description = "Allow TLS traffic from VPC to Endpoints"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.eks_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "within_vpc_communication" {
  security_group_id = aws_security_group.vpc_endpoints_sg.id

  # where the traffic is coming from
  cidr_ipv4 = aws_vpc.eks_vpc.cidr_block

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# allow cluster control plane to reach AWS services over HTTPS
resource "aws_vpc_security_group_egress_rule" "cluster_egress_https" {
  security_group_id = aws_security_group.vpc_endpoints_sg.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}