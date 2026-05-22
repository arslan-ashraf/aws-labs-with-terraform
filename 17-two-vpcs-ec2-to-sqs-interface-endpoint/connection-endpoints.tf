#########################################################################
######################### SQS INTERFACE ENDPOINT ########################
#########################################################################


# dynamically retrieve the correct service name (e.g., com.amazonaws.us-east-1.sqs) 
# for the given region
data "aws_vpc_endpoint_service" "sqs_endpoint" {
  service      = "sqs"
  service_type = "Interface"
}

# vpc interface endpoint's policy document
data "aws_iam_policy_document" "sqs_endpoint_permissions" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    # principals {
    #   type        = "AWS"
    #   identifiers = aws_iam_role.ec2_sqs_access_role.arn
    # }
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


resource "aws_vpc_endpoint" "sqs_interface_endpoint" {
  vpc_id              = aws_vpc.vpc_for_sqs_interface_endpoint.id
  service_name        = data.aws_vpc_endpoint_service.sqs_endpoint.service_name
  vpc_endpoint_type   = "Interface"

  # with private_dns_enabled = true, AWS creates a hidden ROute53 private hosted 
  # zone, that enables access to the endpoint using private DNS hostnames like
  # https://sqs.us-east-1.amazonaws.com/<aws_account_id>/simple_queue to resolve to
  # exact endpoint urls like vpce.<sqs_queue_id-AZ>.<region>.amazonaws.com through
  # AWS's private network, otherwise access to the endpoint happens over the 
  # public internet, however, here we set it to false
  private_dns_enabled = false

  subnet_ids = [aws_subnet.private_subnet_for_sqs_interface_endpoint.id]

  security_group_ids = [aws_security_group.security_group_for_sqs_interface_endpoint.id]

  # add SQS route to the route table for the subnet with EC2 instance
  route_table_ids = [aws_route_table.route_table_for_ec2_subnet.id]

  # Optional: Define an access policy (defaults to Full Access if omitted)
  policy = data.aws_iam_policy_document.sqs_endpoint_permissions.json

  tags = { Name = "sqs_interface_endpoint" }
}