#!/usr/bin/bash

cd terraform-eks-cluster

terraform destroy -auto-approve

cd ../terraform-vpc-network

terraform destroy -auto-approve