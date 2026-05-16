data "aws_iam_policy_document" "ec2_assume_role_document" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_s3_access_role" {
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_document.json
  name = "ec2_s3_access_role"
}

data "aws_iam_policy_document" "ec2_s3_access_permissions" {
  statement {
    effect = "Allow"
    resources = ["${aws_s3_bucket.example_bucket.arn}:*"]
    actions = [
      "s3:ListBucket", 
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
  }
}

# here we create the policy that will take on persmissions defined
# in the JSON document imported by aws_iam_policy_document.lambda_permissions
resource "aws_iam_policy" "s3_bucket_policy" {
  policy = data.aws_iam_policy_document.ec2_s3_access_permissions.json
  name = "s3_bucket_policy"
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs_role_policy_attachment" {
  role = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}