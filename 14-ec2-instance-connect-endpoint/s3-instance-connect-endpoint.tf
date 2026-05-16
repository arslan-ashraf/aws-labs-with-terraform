resource "aws_ec2_instance_connect_endpoint" "instance_connect_endpoint" {
  subnet_id          = aws_subnet.private_subnet_for_ec2_instance_endpoint.id
  security_group_ids = [aws_security_group.security_group_for_ec2_instance_endpoint.id]
  
  tags = { Name = "instance_connect_endpoint" }
}

# data "aws_iam_policy_document" "instance_connect_endpoint_document" {
#   statement {
#     sid    = "EC2InstanceConnectEndpointAccess"
#     effect = "Allow"
#     actions = ["ec2-instance-connect:OpenTunnel"]
#     resources = [aws_ec2_instance_connect_endpoint.instance_connect_endpoint.arn]
#     # resources = ["arn:aws:ec2:*:*:instance-connect-endpoint/*"]
    
#     # Optional: Restrict tunnel creation to specific target private IPs or ports
#     condition {
#       test     = "NumericEquals"
#       variable = "ec2-instance-connect:privatePort"
#       values   = ["22"] # Use 3389 for RDP
#     }
#   }

#   statement {
#     sid    = "EC2InfrastructureDiscovery"
#     effect = "Allow"
#     actions = [
#       "ec2:DescribeInstances",
#       "ec2:DescribeInstanceConnectEndpoints"
#     ]
#     resources = ["*"]
#   }
# }

# # Create the IAM Policy
# resource "aws_iam_policy" "instance_connect_policy" {
#   name        = "EC2InstanceConnectEndpointClientPolicy"
#   description = "Provides permissions to connect to EC2 instances via EIC Endpoint"
#   policy      = data.aws_iam_policy_document.instance_connect_endpoint_document.json
# }
