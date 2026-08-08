# S3 Gateway Endpoint (Free & mandatory for ECR layer downloads)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = local.aws_services.s3
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
}