# to ensure that various EKS addons such as kube-proxy, coredns,
# vpc-cni and others will be downloaded from AWS-owned ECR
# registries, the private ECR endpoint is combined with the
# S3 gateway endpoint so that all addon installation traffic
# remains within the internal AWS network
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
}


locals {
  aws_services = {
    "eks"          = "com.amazonaws.${var.aws_region}.eks"
    "ec2"          = "com.amazonaws.${var.aws_region}.ec2"
    "ecr_api"      = "com.amazonaws.${var.aws_region}.ecr.api"
    "ecr_dkr"      = "com.amazonaws.${var.aws_region}.ecr.dkr"
    "sts"          = "com.amazonaws.${var.aws_region}.sts"
    "logs"         = "com.amazonaws.${var.aws_region}.logs"
    "ssm"          = "com.amazonaws.${var.aws_region}.ssm"
    "autoscaling"  = "com.amazonaws.${var.aws_region}.autoscaling"
  }
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = local.aws_services
  vpc_id              = aws_vpc.eks_vpc.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  
  subnet_ids          = [
    aws_subnet.private_subnet_1.id, 
    aws_subnet.private_subnet_2.id
  ]
}