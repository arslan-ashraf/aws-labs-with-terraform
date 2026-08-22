#!/usr/bin/bash

cd /01-terraform-vpc-network

terraform init

terraform apply -auto-approve

cd ../02-terraform-eks-cluster

terraform init

terraform apply -auto-approve