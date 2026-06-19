# define user/role based policy, trust policy document
data "aws_iam_policy_document" "cloudtrail_trust_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail_role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_trust_policy_document.json
}


# IAM Policy to allow cloudtrail to write to cloudwatch logs
data "aws_iam_policy_document" "cloudtrail_write_to_cloudwatch_permissions" {
  statement {
    effect = "Allow"

    resources = [
      aws_cloudwatch_log_group.secrets_accessed_cloudwatch_log_group.arn,
      "${aws_cloudwatch_log_group.secrets_accessed_cloudwatch_log_group.arn}:*"
    ]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }

}

resource "aws_iam_policy" "cloudtrail_policy" {
  name = "cloudtrail_policy"
  policy = data.aws_iam_policy_document.cloudtrail_write_to_cloudwatch_permissions.json
}


resource "aws_iam_role_policy_attachment" "lambda_s3_role_policy_attachment" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = aws_iam_policy.cloudtrail_policy.arn
}