resource "aws_kms_key" "cloudwatch_kms_key" {
  description             = "KMS key for CloudWatch logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "cloudwatch_key_alias" {
  name          = "alias/${var.name}-encrypt-cloudwatch-logs"
  target_key_id = aws_kms_key.cloudwatch_kms_key.key_id
}

resource "aws_kms_key_policy" "cloudwatch_key_policy" {
  key_id = aws_kms_key.cloudwatch_kms_key.id
  policy = data.aws_iam_policy_document.cloudwatch_key_policy.json
}

data "aws_iam_policy_document" "cloudwatch_key_policy" {
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
    resources = [aws_kms_key.cloudwatch_kms_key.arn]
    principals {
      type        = "AWS"
      identifiers = [local.principal_root_arn]
    }
  }

  statement {
    sid    = "Allow CloudWatch Logs"
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
    resources = [aws_kms_key.cloudwatch_kms_key.arn]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.id}.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/${var.name}-cluster/cluster"]
    }
  }
}