We build on the lab 37 by keeping everything the same but adding the Load Balancer Controller.

Configure your local machine to connect to EKS cluster, update local kubeconfig using the AWS CLI to point to your new cluster:

```
aws eks update-kubeconfig --region us-east-1 --name example_eks_cluster
```