#!/usr/bin/bash

cd 03-k8s-in-terraform

terraform destroy -auto-approve

cd ../02-terraform-karpenter

terraform destroy -auto-approve

cd ../01-terraform-eks-cluster

terraform destroy -auto-approve