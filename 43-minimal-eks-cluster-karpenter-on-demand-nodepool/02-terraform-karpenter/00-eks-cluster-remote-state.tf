data "terraform_remote_state" "example_eks_cluster" {
  backend = "local"

  config = {
    path = "${path.module}/../01-terraform-eks-cluster/terraform.tfstate"
  }
}

locals {
  cluster_outputs       = data.terraform_remote_state.example_eks_cluster.outputs
  cluster_endpoint      = local.cluster_outputs.eks_cluster_endpoint
  certificate_authority = local.eks_cluster_certificate_authority_data
  cluster_name          = local.cluster_outputs.eks_cluster_name
}