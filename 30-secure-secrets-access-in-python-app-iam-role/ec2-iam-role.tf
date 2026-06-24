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

resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy_document.json
}


data "aws_iam_policy_document" "ec2_s3_access_permissions" {
  statement {
    effect    = "Allow"
    
    actions = [
      "s3:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_s3_read_policy" {
  name   = "ec2_s3_read_policy"
  policy = data.aws_iam_policy_document.ec2_s3_access_permissions.json
}


resource "aws_iam_role_policy_attachment" "attach_role_and_policy" {
  role       = aws_iam_role.ec2_secrets_access_role.name
  policy_arn = aws_iam_policy.secrets_read_policy.arn
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_read_s3_profile"
  role = aws_iam_role.ec2_secrets_access_role.name
}