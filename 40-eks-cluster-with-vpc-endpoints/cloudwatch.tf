#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.name}-cluster/cluster"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.cloudwatch_kms_key.arn
}