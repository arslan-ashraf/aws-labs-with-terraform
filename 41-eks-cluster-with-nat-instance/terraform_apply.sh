#!/usr/bin/bash

cd terraform-vpc-network

terraform init

terraform apply -auto-approve

cd ../terraform-eks-cluster

terraform init

terraform apply -auto-approve