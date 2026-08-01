data "aws_iam_policy_document" "ec2_trust_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_secrets_access_role" {
  name = "ec2-secrets-manager-reader-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy_document.json
}


data "aws_iam_policy_document" "ec2_secrets_access_permissions" {
  statement {
    effect    = "Allow"
    
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [var.api_secrets_arn]
  }
}

resource "aws_iam_policy" "secrets_read_policy" {
  name   = "ec2-secrets-manager-read-policy"
  policy = data.aws_iam_policy_document.ec2_secrets_access_permissions.json
}


resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ec2_secrets_access_role.name
  policy_arn = aws_iam_policy.secrets_read_policy.arn
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-secrets-manager-instance-profile"
  role = aws_iam_role.ec2_secrets_access_role.name
}