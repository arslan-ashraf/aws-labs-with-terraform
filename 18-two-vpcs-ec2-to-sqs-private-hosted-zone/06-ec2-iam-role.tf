#########################################################################
############################# EC2 IAM ROLE ##############################
#########################################################################

# EC2 trust policy document
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

resource "aws_iam_role" "ec2_sqs_access_role" {
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_document.json
  name               = "ec2_sqs_access_role"
}


#########################################################################
############################ EC2 IAM POLICY #############################
#########################################################################

data "aws_iam_policy_document" "ec2_sqs_access_permissions" {
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.simple_queue.arn]
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
  }
}


# here we create the policy that will take on persmissions defined
# in the JSON document imported by aws_iam_policy_document.lambda_permissions
resource "aws_iam_policy" "sqs_policy" {
  policy = data.aws_iam_policy_document.ec2_sqs_access_permissions.json
  name   = "SQS_policy"
}

resource "aws_iam_role_policy_attachment" "ec2_s3_role_policy_attachment" {
  role       = aws_iam_role.ec2_sqs_access_role.name
  policy_arn = aws_iam_policy.sqs_policy.arn
}

#########################################################################
####################### EC2 IAM INSTANCE PROFILE ########################
#########################################################################

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_sqs_access_role.name
}