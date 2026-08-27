This lab uses lab 38 as base and continues lab 43.  This time we employ only spot nodes when we perform autoscaling.

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
spot-nodepool   example-ec2-nodeclass   0       True    16m
```

3. Apply the Karpenter autoscaling test:

```
kubectl apply -f 04-kubernetes-files
```

and check the test pods being created:

```
$ kubectl get pods
NAME                                                  READY   STATUS    RESTARTS   A
karpenter-autoscale-spot-test-54cc68968f-5fhd8   0/1     Pending   0          6
karpenter-autoscale-spot-test-54cc68968f-7zjmx   0/1     Pending   0          6
karpenter-autoscale-spot-test-54cc68968f-c5bhl   0/1     Pending   0          6
karpenter-autoscale-spot-test-54cc68968f-pwjbb   0/1     Pending   0          6
karpenter-autoscale-spot-test-54cc68968f-z7dnd   0/1     Pending   0          6
```

and the command below to see the nodes that Karpenter is spinning up on the fly to deploy those pods onto:

```
kubectl get nodeclaims -o wide
```

should show something like this:

```
NAME                       TYPE        CAPACITY    ZONE         NODE
spot-nodepool-4sfj2   t3a.small   spot   us-east-1b   ip-10-0-2-114.e
spot-nodepool-fv8s6   t3a.small   spot   us-east-1b   ip-10-0-2-146.e
```

If no nodes are spun up, check the Karpenter logs as follows:

First to get the labels for Karpenter pods, run:

```
kubectl describe pods <karpenter_pod> -n kube-system
```

This will return one of the labels as `app.kubernetes.io/name=karpenter`.

Then run:

```
kubectl logs -n kube-system -l app.kubernetes.io/name=karpenter --tail=3
```

To see something like this:

```
{"level":"ERROR","time":"2026-08-27T20:09:44.386Z","logger":"controller","message":"could not schedule pod","commit":"f913f41","controller":"provisioner","namespace":"","name":"","reconcileID":"d142ec5a-6ed6-4b34-a3af-821a7ad3c70a","Pod":{"name":"karpenter-autoscale-spot-test-5d6d65cd9b-mm9x7","namespace":"default"},"error":"nodepool requirements filtered out all available instance types"}
{"level":"ERROR","time":"2026-08-27T20:09:44.386Z","logger":"controller","message":"could not schedule pod","commit":"f913f41","controller":"provisioner","namespace":"","name":"","reconcileID":"d142ec5a-6ed6-4b34-a3af-821a7ad3c70a","Pod":{"name":"karpenter-autoscale-spot-test-5d6d65cd9b-hhrld","namespace":"default"},"error":"nodepool requirements filtered out all available instance types"}
{"level":"ERROR","time":"2026-08-27T20:09:44.386Z","logger":"controller","message":"could not schedule pod","commit":"f913f41","controller":"provisioner","namespace":"","name":"","reconcileID":"d142ec5a-6ed6-4b34-a3af-821a7ad3c70a","Pod":{"name":"karpenter-autoscale-spot-test-5d6d65cd9b-cmpb2","namespace":"
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

and this should show

```
No resources found
```

5. Cleanup and destroy AWS resources:

```
./terraform_destroy.sh
```