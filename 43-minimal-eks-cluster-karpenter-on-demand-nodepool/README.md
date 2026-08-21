This is a continuation of lab 38.  We remove all of the addons except for Pod Identity Agent which is always necessary for pods to have permission to call AWS APIs and we also install Karpenter in the EKS cluster so we can provision the worker nodes dynamically to perform autoscaling.

Configure your local machine to connect to EKS cluster, update local kubeconfig using the AWS CLI to point to your new cluster:

```
aws eks update-kubeconfig --region us-east-1 --name example_eks_cluster
```