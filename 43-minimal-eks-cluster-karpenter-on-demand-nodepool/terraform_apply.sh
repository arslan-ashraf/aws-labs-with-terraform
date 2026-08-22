#!/usr/bin/bash

cd 01-terraform-eks-cluster

terraform init

terraform apply -auto-approve

cd ../02-terraform-karpenter

terraform init

terraform apply -auto-approve