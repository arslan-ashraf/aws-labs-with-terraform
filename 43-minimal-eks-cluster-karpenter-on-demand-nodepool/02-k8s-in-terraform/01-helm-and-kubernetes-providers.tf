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

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.example_eks_cluster.id
}

locals {
  cluster_outputs       = data.terraform_remote_state.example_eks_cluster.outputs
  cluster_endpoint      = local.cluster_outputs.eks_cluster_endpoint
  certificate_authority = local.eks_cluster_certificate_authority_data
}

# connect Helm Terraform API to EKS cluster
# allows installation of Helm charts using Terraform, we use it
# to install the load balancer controller
provider "helm" {
  kubernetes = {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = base64decode(local.certificate_authority)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


# connect Kubernetes Terraform API to EKS cluster
# allows creation of Kubernetes resources using Terraform instead
# of yaml files, this is only a best practice when Terraform results
# need to be dynamically injected into a Kubernetes resource
provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = base64decode(local.certificate_authority)
  token                  = data.aws_eks_cluster_auth.cluster.token
}