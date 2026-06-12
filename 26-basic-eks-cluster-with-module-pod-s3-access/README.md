This labs creates a basic EKS cluster using the official AWS EKS module `terraform-aws-modules/eks/aws` and similarly, the VPC is also created using the official AWS VPC module `terraform-aws-modules/vpc/aws`.

After the Kubernetes cluster is deployed, configure `kubectl` with:
```
aws eks update-kubeconfig \
  --region us-east-1 \
  --name basic-eks-cluster
```