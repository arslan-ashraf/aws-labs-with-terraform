resource "aws_ec2_instance_connect_endpoint" "instance_connect_endpoint" {
  subnet_id          = aws_subnet.private_subnet_for_ec2_instance_endpoint.id
  security_group_ids = [aws_security_group.security_group_for_ec2_instance_endpoint.id]

  tags = { Name = "instance_connect_endpoint" }
}


# dynamically retrieve the correct service name (e.g., com.amazonaws.us-east-1.s3) 
# for the given region
data "aws_vpc_endpoint_service" "s3_endpoint" {
  service      = "s3"
  service_type = "Gateway"
}

# vpc gateway endpoint's policy document
data "aws_iam_policy_document" "s3_endpoint_permissions" {
  statement {
    effect    = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.example_bucket.arn, 
      "${aws_s3_bucket.example_bucket.arn}/*"
    ]
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
  }
}


resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.example_vpc.id
  service_name      = data.aws_vpc_endpoint_service.s3_endpoint.service_name
  vpc_endpoint_type = "Gateway"

  # add S3 route to the route table for the subnet with EC2 instance
  route_table_ids = [aws_route_table.route_table_for_ec2_subnet.id]

  # Optional: Define an access policy (defaults to Full Access if omitted)
  policy = data.aws_iam_policy_document.s3_endpoint_permissions.json

  tags = { Name = "s3-gateway-endpoint" }
}