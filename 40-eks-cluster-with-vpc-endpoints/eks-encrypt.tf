#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "eks_secrets_kms_key" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
resource "aws_kms_alias" "eks_secrets_key_alias" {
  name          = "alias/${var.name}-encrypt-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets_kms_key.key_id
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy
resource "aws_kms_key_policy" "eks_secrets_key_policy" {
  key_id = aws_kms_key.eks_secrets_kms_key.id
  policy = data.aws_iam_policy_document.eks_secrets_key_policy.json
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "eks_secrets_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:Create*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource"
    ]
    resources = [aws_kms_key.eks_secrets_kms_key.arn]
    principals {
      type        = "AWS"
      identifiers = [local.principal_root_arn]
    }
  }

  statement {
    sid    = "Allow EKS Service"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:RetireGrant"
    ]
    resources = [aws_kms_key.eks_secrets_kms_key.arn]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}