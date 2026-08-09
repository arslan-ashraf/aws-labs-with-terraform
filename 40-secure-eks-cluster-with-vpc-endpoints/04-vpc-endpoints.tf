# S3 Gateway Endpoint (Free & mandatory for ECR image downloads)
# CoreDNS & and other addons
# (kube-proxy, coredns, vpc-cni) will attempt to download from
# AWS-owned ECR registries. The private ECR endpoint combined
# with the S3 Gateway endpoint safely fulfills these requests
# within the internal AWS network structure
resource "aws_vpc_endpoint" "s3" {
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
  for_each            = local.services
  vpc_id              = aws_vpc.eks_vpc.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}