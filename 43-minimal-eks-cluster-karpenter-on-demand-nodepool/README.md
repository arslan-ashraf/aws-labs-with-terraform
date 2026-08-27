This lab uses lab 38 as base.  We remove all of the addons except for Pod Identity Agent which is always necessary for pods to have IAM permissions to call the necessary AWS APIs and we also install Karpenter in the EKS cluster so we can provision the worker nodes dynamically to perform autoscaling.

1. Run the Terraform config using the script:

```
./terraform_apply.sh
```

2. Check the nodes in the EKS Cluster:

```
kubectl get nodes -o wide
```

This will only show one node created in the cluster through EKS Node Group.

Now we can also see the EC2NodeClass and NodePool objects created in the EKS Cluster.

```
$ kubectl get ec2nodeclass
```

should return something like this:

```
NAME                    READY   AGE
example-ec2-nodeclass   True    15m
```

and 

```
kubectl get nodepool
```

should show something like this:

```
NAME                 NODECLASS               NODES   READY   AGE
on-demand-nodepool   example-ec2-nodeclass   0       True    16m
```

3. Apply the Karpenter autoscaling test:

```
kubectl apply -f 04-kubernetes-files
```

and check the test pods being created:

```
$ kubectl get pods
NAME                                                  READY   STATUS    RESTARTS   A
karpenter-autoscale-on-demand-test-54cc68968f-5fhd8   0/1     Pending   0          6
karpenter-autoscale-on-demand-test-54cc68968f-7zjmx   0/1     Pending   0          6
karpenter-autoscale-on-demand-test-54cc68968f-c5bhl   0/1     Pending   0          6
karpenter-autoscale-on-demand-test-54cc68968f-pwjbb   0/1     Pending   0          6
karpenter-autoscale-on-demand-test-54cc68968f-z7dnd   0/1     Pending   0          6
```

and the command below to see the nodes that Karpenter is spinning up on the fly to deploy those pods onto:

```
kubectl get nodeclaims -o wide
```

should show something like this:

```
NAME                       TYPE        CAPACITY    ZONE         NODE
on-demand-nodepool-4sfj2   t3a.small   on-demand   us-east-1b   ip-10-0-2-114.e
on-demand-nodepool-fv8s6   t3a.small   on-demand   us-east-1b   ip-10-0-2-146.e
```

4. Delete the deployment pods 

```
kubectl delete -f 04-kubernetes-files
```

and after `30 seconds`, Karpenter will begin to remove the added EC2 instances that it provisioned before.  The reason for the 30 second wait is that the `NodePool` resource contains the block:

```
disruption = {
	consolidationPolicy = "WhenEmptyOrUnderutilized"
	consolidateAfter    = "30s"
}
```

Run the command below after more than 30 seconds:

```
kubectl get nodeclaims
```

and this should 

```
No resources found
```