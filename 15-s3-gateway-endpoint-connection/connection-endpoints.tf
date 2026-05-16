resource "aws_ec2_instance_connect_endpoint" "instance_connect_endpoint" {
  subnet_id          = aws_subnet.private_subnet_for_ec2_instance_endpoint.id
  security_group_ids = [aws_security_group.security_group_for_ec2_instance_endpoint.id]
  
  tags = { Name = "instance_connect_endpoint" }
}




# 1. Look up the S3 service name for your current region
# dynamically retrieve the correct service name (e.g., com.amazonaws.us-east-1.s3) 
# for the given region
data "aws_vpc_endpoint_service" "s3_endpoint" {
  service      = "s3"
  service_type = "Gateway"
}

# 2. Create the S3 Gateway VPC Endpoint
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.main.id
  service_name      = data.aws_vpc_endpoint_service.s3_endpoint.service_name
  vpc_endpoint_type = "Gateway"

  # add S3 routes to the route table for the subnet with EC2 instance
  route_table_ids = [aws_route_table.route_table_for_ec2_subnet.id]

  # Optional: Define an access policy (defaults to Full Access if omitted)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSpecificS3Actions"
        Effect    = "Allow"
        Principal = "*"
        Resource  = ["${aws_s3_bucket.example_bucket.arn}:*"]
        Action    = [
          "s3:GetObject", 
          "s3:PutObject", 
          "s3:ListBucket", 
          "s3:DeleteObject"
        ]
      }
    ]
  })

  tags = { Name = "s3-gateway-endpoint" }
}
