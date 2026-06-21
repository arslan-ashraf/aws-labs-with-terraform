data "aws_iam_policy_document" "ec2_assume_role_document" {
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

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Define the IAM Policy allowing the instance to read specific secrets
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