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


data "aws_iam_policy_document" "ec2_sqs_access_permissions" {
  statement {
    effect    = "Allow"
    
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]

    resources = [var.api_secrets_arn]
  }
}

resource "aws_iam_policy" "secrets_read_policy" {
  name        = "ec2-secrets-manager-read-policy"
  description = "Allows EC2 instances to read specific API keys from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        # Replace the ARN below with your specific secret's ARN to enforce least privilege
        Resource = "*" 
      }
    ]
  })
}

# 3. Attach the Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ec2_secrets_access_role.name
  policy_arn = aws_iam_policy.secrets_read_policy.arn
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-secrets-manager-instance-profile"
  role = aws_iam_role.ec2_secrets_access_role.name
}