This is a continuation of lab 38.  We keep everything the same but install Karpenter in the EKS cluster so we can provision the worker nodes dynamically.

Configure your local machine to connect to EKS cluster, update local kubeconfig using the AWS CLI to point to your new cluster:

```
aws eks update-kubeconfig --region us-east-1 --name example_eks_cluster
```