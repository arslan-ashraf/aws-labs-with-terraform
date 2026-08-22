data "terraform_remote_state" "karpenter" {
  backend = "local"

  config = {
    path = "${path.module}/../02-terraform-karpenter/terraform.tfstate"
  }
}

locals {
  karpenter_outputs     = data.terraform_remote_state.karpenter.outputs
  eks_cluster_endpoint  = local.cluster_outputs.eks_cluster_endpoint
  eks_cluster_name      = local.cluster_outputs.eks_cluster_name
  certificate_authority = local.cluster_outputs.eks_cluster_certificate_authority_data
}