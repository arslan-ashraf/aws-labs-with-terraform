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
    effect = "Allow"

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    # principals {
    #   type        = "AWS"
    #   identifiers = aws_iam_role.ec2_sqs_access_role.arn
    # }
    resources = [aws_sqs_queue.simple_queue.arn]
  }
}


resource "aws_vpc_endpoint" "sqs_interface_endpoint" {
  vpc_id              = aws_vpc.vpc_for_sqs_interface_endpoint.id
  service_name        = data.aws_vpc_endpoint_service.sqs_endpoint.service_name
  vpc_endpoint_type   = "Interface"

  # enable private DNS hostnames so resources can resolve public domain hostnames
  # like "sqs.<region>.amazonaws.com" locally, a private Route 53 hosted zone is 
  # associated with your VPC to override default AWS public endpoints
  # setting true allows instances in your VPC to reach an AWS service using its default 
  # public DNS name (e.g., sqs.us-east-1.amazonaws.com), but route the traffic 
  # privately within AWS's network through the endpoint instead of the public internet
  # WARNING: AWS creates a Private Hosted Zone under the hood and hides the underlying 
  # hosted zone ID from you, preventing you from associating it with other VPCs
  private_dns_enabled = false

  subnet_ids = [aws_subnet.private_subnet_for_sqs_interface_endpoint.id]

  security_group_ids = [aws_security_group.security_group_for_sqs_interface_endpoint.id]

  # Optional: Define an access policy (defaults to Full Access if omitted)
  policy = data.aws_iam_policy_document.sqs_endpoint_permissions.json

  tags = { Name = "sqs_interface_endpoint" }
}