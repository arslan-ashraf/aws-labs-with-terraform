Configure your local machine to connect to EKS cluster, update local kubeconfig using the AWS CLI to point to your new cluster:
```
aws eks update-kubeconfig --region us-east-1 --name minimal-eks-cluster
```


kubectl get nodes