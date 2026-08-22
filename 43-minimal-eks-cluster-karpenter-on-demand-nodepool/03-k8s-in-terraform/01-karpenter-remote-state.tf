data "terraform_remote_state" "karpenter" {
  backend = "local"

  config = {
    path = "${path.module}/../02-terraform-karpenter/terraform.tfstate"
  }
}

locals {
  karpenter_outputs       = data.terraform_remote_state.karpenter.outputs
  karpenter_node_role_arn = karpenter_outputs.karpenter_node_role_arn
}