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

# HELM Provider
provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host = aws_eks_cluster.main.endpoint 
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
}