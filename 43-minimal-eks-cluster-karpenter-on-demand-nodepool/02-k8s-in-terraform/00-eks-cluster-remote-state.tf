data "terraform_remote_state" "eks_cluster" {
  backend = "local"

  config = {
    path = "${path.module}/../01-terraform-eks-cluster/terraform.tfstate"
  }
}