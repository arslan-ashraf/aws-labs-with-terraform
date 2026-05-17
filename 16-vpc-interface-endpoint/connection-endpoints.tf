#########################################################################
################### EC2 INSTANCE CONNECT ENDPOINT #######################
#########################################################################

resource "aws_ec2_instance_connect_endpoint" "instance_connect_endpoint" {
  subnet_id          = aws_subnet.private_subnet_for_ec2_instance_endpoint.id
  security_group_ids = [aws_security_group.security_group_for_ec2_instance_endpoint.id]

  tags = { Name = "instance_connect_endpoint" }
}


#########################################################################
######################### SQS INTERFACE ENDPOINT ########################
#########################################################################


# dynamically retrieve the correct service name (e.g., com.amazonaws.us-east-1.sqs) 
# for the given region
data "aws_vpc_endpoint_service" "sqs_endpoint" {
  service      = "sqs"
  service_type = "Interface"
}

# vpc gateway endpoint's policy document
data "aws_iam_policy_document" "sqs_endpoint_permissions" {
  statement {
    effect    = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
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


resource "aws_vpc_endpoint" "sqs_gateway_endpoint" {
  vpc_id            = aws_vpc.example_vpc.id
  service_name      = data.aws_vpc_endpoint_service.sqs_endpoint.service_name
  vpc_endpoint_type = "Interface"

  # add SQS route to the route table for the subnet with EC2 instance
  route_table_ids = [aws_route_table.route_table_for_ec2_subnet.id]

  # Optional: Define an access policy (defaults to Full Access if omitted)
  policy = data.aws_iam_policy_document.sqs_endpoint_permissions.json

  tags = { Name = "sqs_gateway_endpoint" }
}