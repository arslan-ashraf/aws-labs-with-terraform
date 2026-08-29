This lab uses lab 43 as base.  This time we implement **Pod Disruption Budget** along with **Horizontal Pod Autoscaler**.  Previously, we were manually running a test K8s deployment in `04-kubernetes-files` where the number of extra pods was known in advance and Karpenter was provisioning the compute to schedule those pods.

But in production, traffic scales with users so we don't know how many pods we need in advance.  This is where the HPA or **Horizontal Pod Autoscaler** comes in.  HPA queries the **Metrics Server** which continuously collects metrics about pods and other things and HPA polls the Metrics Server every 15 seconds by default.

HPA then determines whether we need more or less pods and Karpenter then provisions or deprovisions compute to serve the required pods.

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

3. Apply the HPA and Karpenter autoscaling test:

# Open four terminal windows and run each command in each terminal

Window 1. See HPA in action:
```
kubectl get hpa hpa-karpenter-test -w
```

Window 2. See the events inside the EKS cluster:
```
kubectl get events --sort-by=.lastTimestamp -w
```

Window 3. See the nodes being provisioned:
```
kubectl get nodes -l karpenter.sh/capacity-type=on-demand -w
```

Window 4. See the nodes and their status provisioned by Karpenter:
```
kubectl get nodes -l karpenter.sh/capacity-type=spot -w
```

```
kubectl apply -f 04-kubernetes-files
```

and check the test pods being created:

```
kubectl get pods -l app=hpa-karpenter-test -w
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

5. Cleanup and destroy AWS resources:

```
./terraform_destroy.sh
```