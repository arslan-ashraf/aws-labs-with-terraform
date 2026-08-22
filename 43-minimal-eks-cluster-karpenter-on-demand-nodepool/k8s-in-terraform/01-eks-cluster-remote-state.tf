data "terraform_remote_state" "vpc_network" {
  backend = "local"

  config = {
    path = "${path.module}/../terraform-eks-cluster/terraform.tfstate"
  }
}