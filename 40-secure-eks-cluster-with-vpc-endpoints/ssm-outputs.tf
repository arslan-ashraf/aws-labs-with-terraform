#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
resource "aws_ssm_parameter" "infra_output" {
  name        = "/${var.name}/output"
  description = "Infrastructure layer resources for platform consumption"
  type        = "SecureString"
  key_id      = aws_kms_key.ssm_kms_key.id
  value = jsonencode({
    "cluster_name" : aws_eks_cluster.main.name,
    "cluster_endpoint" : aws_eks_cluster.main.endpoint,
    "cluster_certificate_authority_data" : aws_eks_cluster.main.certificate_authority[0].data,
    "vpc_id" : module.vpc.vpc.id,
    "region" : var.region,
    "public_subnet_ids" : [for subnet in module.vpc.public_subnets : subnet.id],
    "private_subnet_ids" : [for subnet in module.vpc.private_subnets : subnet.id],
    "ecr_repository_url" : aws_ecr_repository.image_repo.repository_url,
    "ecr_kms_key_arn" : aws_kms_key.ecr_kms_key.arn,
    "cloudwatch_kms_key_arn" : aws_kms_key.cloudwatch_kms_key.arn,
    "ssm_kms_key_arn" : aws_kms_key.ssm_kms_key.arn,
    "aws_load_balancer_controller_role_arn" : aws_iam_role.aws_load_balancer_controller.arn,
    "karpenter_role_arn" : aws_iam_role.karpenter.arn,
    "karpenter_interruption_queue_name" : aws_sqs_queue.karpenter_interruption.name
  })
}