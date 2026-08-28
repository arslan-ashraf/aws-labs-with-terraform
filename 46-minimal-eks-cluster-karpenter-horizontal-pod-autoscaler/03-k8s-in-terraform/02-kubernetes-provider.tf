terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.55.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2.0"
    }

  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}


# connect Kubernetes Terraform API to EKS cluster
# allows creation of Kubernetes resources using Terraform instead
# of yaml files, this is only a best practice when Terraform results
# need to be dynamically injected into a Kubernetes resource
provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(local.certificate_authority)
  token                  = data.aws_eks_cluster_auth.cluster.token
}