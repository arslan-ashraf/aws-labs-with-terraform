This is a continuation of lab 38.  We remove all of the addons except for Pod Identity Agent which is always necessary for pods to have permission to call AWS APIs and we also install Karpenter in the EKS cluster so we can provision the worker nodes dynamically to perform autoscaling.

1. Run the Terraform config.

2. Apply the Terraform config and configure the local machine to connect to EKS cluster, update local kubeconfig using the AWS CLI to point to your new cluster:

```
aws eks update-kubeconfig --region us-east-1 --name example_eks_cluster
```

3. Apply the Karpenter autoscaling test:

```
kubectl apply -f 03-kubernetes-files/karpenter-on-demand-autoscaling-test.yaml
```





```
kubectl get nodeclaims -o wide
```

```
NAME                       TYPE        CAPACITY    ZONE         NODE
on-demand-nodepool-4sfj2   t3a.small   on-demand   us-east-1b   ip-10-0-2-114.e
on-demand-nodepool-fv8s6   t3a.small   on-demand   us-east-1b   ip-10-0-2-146.e
```