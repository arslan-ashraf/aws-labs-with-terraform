data "terraform_remote_state" "example_eks_cluster" {
  backend = "local"

  config = {
    path = "${path.module}/../01-terraform-eks-cluster/terraform.tfstate"
  }
}