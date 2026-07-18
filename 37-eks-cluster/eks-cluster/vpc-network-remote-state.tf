data "terraform_remote_state" "vpc_network" {
  backend = "local"

  config = {
    path = "${path.module}/../vpc-network/terraform.tfstate"
  }
}