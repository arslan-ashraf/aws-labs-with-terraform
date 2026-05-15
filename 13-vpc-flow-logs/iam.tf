data "aws_iam_policy_document" "vpc_flow_logs_assume_role_document" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role_document.json
  name = "vpc_flow_logs_role"
}

data "aws_iam_policy_document" "cloudwatch_permissions" {
  statement {
    effect = "Allow"
    resources = ["${aws_cloudwatch_log_group.vpc_logs_group.arn}:*"]
    actions = [
      "logs:CreateLogStream", 
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
  }
}

# here we create the policy that will take on persmissions defined
# in the JSON document imported by aws_iam_policy_document.lambda_permissions
resource "aws_iam_policy" "vpc_flow_logs_policy" {
  policy = data.aws_iam_policy_document.cloudwatch_permissions.json
  name = "vpc_flow_logs_policy"
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs_role_policy_attachment" {
  role = aws_iam_role.vpc_flow_logs_role.name
  policy_arn = aws_iam_policy.vpc_flow_logs_policy.arn
}