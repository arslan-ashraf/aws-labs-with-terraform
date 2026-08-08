locals {
  services = {
    "eks"          = "com.amazonaws.us-east-1.eks"
    "ec2"          = "com.amazonaws.us-east-1.ec2"
    "ecr_api"      = "com.amazonaws.us-east-1.ecr.api"
    "ecr_dkr"      = "com.amazonaws.us-east-1.ecr.dkr"
    "sts"          = "com.amazonaws.us-east-1.sts"
    "logs"         = "com.amazonaws.us-east-1.logs"
    "ssm"          = "com.amazonaws.us-east-1.ssm"
    "autoscaling"  = "com.amazonaws.us-east-1.autoscaling"
  }
}