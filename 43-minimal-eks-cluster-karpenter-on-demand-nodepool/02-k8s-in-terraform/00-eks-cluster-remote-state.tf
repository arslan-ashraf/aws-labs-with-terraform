data "terraform_remote_state" "vpc_network" {
  backend = "local"

  config = {
    path = "${path.module}/../01-terraform-eks-cluster/terraform.tfstate"
  }
}