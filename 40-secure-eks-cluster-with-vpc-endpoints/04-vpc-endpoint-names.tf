locals {
  services = {
    "eks"          = "com.amazonaws.${var.aws_region}.eks"
    "ec2"          = "com.amazonaws.${var.aws_region}.ec2"
    "ecr_api"      = "com.amazonaws.${var.aws_region}.ecr.api"
    "ecr_dkr"      = "com.amazonaws.${var.aws_region}.ecr.dkr"
    "sts"          = "com.amazonaws.${var.aws_region}.sts"
    "logs"         = "com.amazonaws.${var.aws_region}.logs"
    "ssm"          = "com.amazonaws.${var.aws_region}.ssm"
    "autoscaling"  = "com.amazonaws.${var.aws_region}.autoscaling"
  }
}