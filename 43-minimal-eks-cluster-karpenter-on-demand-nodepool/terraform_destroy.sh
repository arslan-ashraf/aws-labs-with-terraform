#!/usr/bin/bash

cd 02-terraform-eks-cluster

terraform destroy -auto-approve

cd ../01-terraform-vpc-network

terraform destroy -auto-approve