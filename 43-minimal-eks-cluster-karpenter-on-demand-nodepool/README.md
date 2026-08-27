This lab uses lab 38 as base.  We remove all of the addons except for Pod Identity Agent which is always necessary for pods to have IAM permissions to call the necessary AWS APIs and we also install Karpenter in the EKS cluster so we can provision the worker nodes dynamically to perform autoscaling.

1. Run the Terraform config using the script:

```
./terraform_apply.sh
```

2. Apply the Karpenter autoscaling test:

```
kubectl apply -f 04-kubernetes-files
```

```
$ kubectl get ec2nodeclass
```

```
NAME                    READY   AGE
example-ec2-nodeclass   True    15m
```

```
kubectl get nodepool
```

```
NAME                 NODECLASS               NODES   READY   AGE
on-demand-nodepool   example-ec2-nodeclass   0       True    16m
```


```
kubectl get nodeclaims -o wide
```

```
NAME                       TYPE        CAPACITY    ZONE         NODE
on-demand-nodepool-4sfj2   t3a.small   on-demand   us-east-1b   ip-10-0-2-114.e
on-demand-nodepool-fv8s6   t3a.small   on-demand   us-east-1b   ip-10-0-2-146.e
```