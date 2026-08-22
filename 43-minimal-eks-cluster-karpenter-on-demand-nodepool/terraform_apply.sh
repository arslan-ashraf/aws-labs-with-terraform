#!/usr/bin/bash

cd 01-terraform-eks-cluster

terraform init

terraform fmt -recursive

terraform apply -auto-approve

aws eks update-kubeconfig --region us-east-1 --name example_eks_cluster

# cd ../02-terraform-karpenter

# terraform init

# terraform fmt -recursive

# terraform apply -auto-approve

# cd ../03-k8s-in-terraform

# terraform init

# terraform fmt -recursive

# terraform apply auto-approve