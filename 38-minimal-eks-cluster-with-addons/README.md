We build on the previous lab by keeping everything the same but adding various AWS EKS Addons such as Pod Identity Agent and various others.  Additionally, we also configure Pod Identity Associations to for pods in the EKS cluster to gain access to AWS services such as S3, EBS volumes and more.

Configure your local machine to connect to EKS cluster, update local kubeconfig using the AWS CLI to point to your new cluster:

```
aws eks update-kubeconfig --region us-east-1 --name example_eks_cluster
```