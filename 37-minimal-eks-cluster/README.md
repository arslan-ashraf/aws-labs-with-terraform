In this lab, we create a very basic AWS EKS cluster with only a single node in a public subnet to get the cluster up and running.

Run the Terraform config and configure your local machine to connect to EKS cluster, update local kubeconfig using the AWS CLI to point to your new cluster:

```
aws eks update-kubeconfig --region us-east-1 --name example_eks_cluster
```

To see the worker nodes, run command and check the IP address of the EC2 instance:

```
kubectl get nodes -o wide
```