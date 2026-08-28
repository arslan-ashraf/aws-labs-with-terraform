This lab uses lab 38 as base and builds on lab 44.  This time we use Pod Disruption Budget to ensure our application running on spot instances has zero downtime.  We will ensure this with EventBridge rules and an SQS queue.

When AWS wants to take back spot instances, it sends messages which we can pick using EventBridge rules and send them to the SQS queue.  Karpenter (during installation) will be configured to poll this queue which it does by default every 10 seconds.

Karpenter requires the IAM permissions which we add in its IAM policy.  We need to create a service account for creating spot instances so we add the following:

```
resource "aws_iam_service_linked_role" "ec2_spot" {
  aws_service_name = "spot.amazonaws.com"
}
```

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
spot-nodepool   	 example-ec2-nodeclass   0       True    16m
```

3. Apply the Karpenter autoscaling test:

```
kubectl apply -f 04-kubernetes-files
```

and check the test pods being created:

```
$ kubectl get pods
NAME                         READY   STATUS    RESTARTS   A
spot-test-54cc68968f-5fhd8   0/1     Pending   0          6
spot-test-54cc68968f-7zjmx   0/1     Pending   0          6
spot-test-54cc68968f-c5bhl   0/1     Pending   0          6
spot-test-54cc68968f-pwjbb   0/1     Pending   0          6
spot-test-54cc68968f-z7dnd   0/1     Pending   0          6
```

and the command below to see the nodes that Karpenter is spinning up on the fly to deploy those pods onto:

```
kubectl get nodeclaims -o wide
```

should show something like this:

```
NAME                  TYPE       CAPACITY   ZONE         NODE                        READY   AGE
spot-nodepool-7lqht   t2.small   spot       us-east-1a   ip-10-0-1-33.ec2.internal   True    7m25s
```

5. Simulate AWS spot interruption - we will send a message to the SQS queue which will be of the same type that AWS sends when it wants to take back a spot instance:

# Open four terminal windows and run each command in each terminal

Window 1. See spot nodes provisioned by Karpenter:
```
kubectl get nodes -l karpenter.sh/capacity-type=spot -w
```

Window 2. See the nodeclaims:
```
kubectl get nodeclaims -w
```

Window 3. See pods being moved from one spot node to another:
```
kubectl get pods -l app=spot-test -o wide -w
```

Window 4. Get the spot instance ID from command:
```
kubectl get nodes -l karpenter.sh/capacity-type=spot -o json
```

6. Get the SQS queue URL, save them in environment variables and send the interruption message:
```
aws sqs send-message \
  --queue-url "$QUEUE_URL" \
  --message-body "{
    \"version\": \"0\",
    \"id\": \"test-interrupt-$(date +%s)\",
    \"detail-type\": \"EC2 Spot Instance Interruption Warning\",
    \"source\": \"aws.ec2\",
    \"account\": \"123456789012\",
    \"time\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
    \"region\": \"us-east-1\",
    \"resources\": [
      \"arn:aws:ec2:us-east-1:123456789012:instance/$SPOT_INSTANCE_ID\"
    ],
    \"detail\": {
      \"instance-id\": \"$SPOT_INSTANCE_ID\",
      \"instance-action\": \"terminate\"
    }
  }"
```

7. Watch the automation in action:

Karpenter logs:
```
kubectl logs -n kube-system -l app.kubernetes.io/name=karpenter -f | grep -E "interrupt|cordon|drain"
```

Window 1. See spot nodes provisioned by Karpenter:
```
kubectl get nodes -l karpenter.sh/capacity-type=spot -w
```

This should show something like:
```
{"level":"INFO","time":"2026-08-28T20:11:37.379Z","logger":"controller","message":"initiating delete from interruption message","commit":"f913f41","controller":"interruption","namespace":"","name":"","reconcileID":"e6294c15-ad3d-492f-8f15-f149e5406dd9","queue":"karpenter_ec2_spot_interruption_queue_for_example_eks_cluster","messageKind":"spot_interrupted","NodeClaim":{"name":"spot-nodepool-7lqht"},"action":"CordonAndDrain","Node":{"name":"ip-10-0-1-33.ec2.internal"}}
```


Window 2. See the nodeclaims:
```
kubectl get nodeclaims -w
```

This should show something like:
```
NAME                  TYPE       CAPACITY   ZONE         NODE                        READY   AGE
spot-nodepool-7lqht   t2.small   spot       us-east-1a   ip-10-0-1-33.ec2.internal   True    7m25s
spot-nodepool-7lqht   t2.small   spot       us-east-1a   ip-10-0-1-33.ec2.internal   True    9m41s
spot-nodepool-7lqht   t2.small   spot       us-east-1a   ip-10-0-1-33.ec2.internal   True    9m41s
spot-nodepool-7lqht   t2.small   spot       us-east-1a   ip-10-0-1-33.ec2.internal   True    9m41s
spot-nodepool-4dqlv                                                                          0s
spot-nodepool-4dqlv                                                                          0s
spot-nodepool-4dqlv                                                                  Unknown   0s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a                               Unknown   4s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a                               Unknown   4s
spot-nodepool-7lqht   t2.small    spot       us-east-1a   ip-10-0-1-33.ec2.internal   True      10m
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   Unknown   27s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   Unknown   29s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   Unknown   41s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   Unknown   41s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   Unknown   42s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      44s
spot-nodepool-7lqht   t2.small    spot       us-east-1a   ip-10-0-1-33.ec2.internal   True      10m
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      53s
spot-nodepool-7lqht   t2.small    spot       us-east-1a   ip-10-0-1-33.ec2.internal   True      10m
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      63s
spot-nodepool-7lqht   t2.small    spot       us-east-1a   ip-10-0-1-33.ec2.internal   True      10m
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      93s
spot-nodepool-7lqht   t2.small    spot       us-east-1a   ip-10-0-1-33.ec2.internal   True      11m
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      3m45s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      3m45s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      4m15s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      4m34s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      4m34s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      4m34s
spot-nodepool-4dqlv   t3a.small   spot       us-east-1a   ip-10-0-1-49.ec2.internal   True      5m6s
```


Window 3. See pods being moved from one spot node to another:
```
kubectl get pods -l app=spot-test -o wide -w
```

This should show something like:
```
spot-test-647b569fd7-c9jp6   1/1     Running   0          7m43s   10.0.1.89    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-cv6kq   1/1     Running   0          7m43s   10.0.1.87    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-fnhqp   1/1     Running   0          7m43s   10.0.1.233   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-jrn4n   1/1     Running   0          7m43s   10.0.1.215   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-vn6rn   1/1     Running   0          7m43s   10.0.1.219   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-c9jp6   1/1     Running   0          10m     10.0.1.89    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-c9jp6   1/1     Terminating   0          10m     10.0.1.89    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-fnhqp   1/1     Running       0          10m     10.0.1.233   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-wl6vj   0/1     Pending       0          0s      <none>       <none>                      <none>           <none>
spot-test-647b569fd7-c9jp6   1/1     Terminating   0          10m     10.0.1.89    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-fnhqp   1/1     Terminating   0          10m     10.0.1.233   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-wl6vj   0/1     Pending       0          0s      <none>       <none>                      <none>           <none>
spot-test-647b569fd7-fnhqp   1/1     Terminating   0          10m     10.0.1.233   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-7lg8v   0/1     Pending       0          0s      <none>       <none>                      <none>           <none>
spot-test-647b569fd7-7lg8v   0/1     Pending       0          0s      <none>       <none>                      <none>           <none>
spot-test-647b569fd7-c9jp6   0/1     Completed     0          10m     10.0.1.89    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-fnhqp   0/1     Completed     0          10m     10.0.1.233   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-fnhqp   0/1     Completed     0          10m     10.0.1.233   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-fnhqp   0/1     Completed     0          10m     10.0.1.233   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-c9jp6   0/1     Completed     0          10m     10.0.1.89    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-c9jp6   0/1     Completed     0          10m     10.0.1.89    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-wl6vj   0/1     Pending       0          28s     <none>       <none>                      <none>           <none>
spot-test-647b569fd7-7lg8v   0/1     Pending       0          28s     <none>       <none>                      <none>           <none>
spot-test-647b569fd7-wl6vj   0/1     Pending       0          42s     <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-7lg8v   0/1     Pending       0          42s     <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-wl6vj   0/1     ContainerCreating   0          42s     <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-7lg8v   0/1     ContainerCreating   0          42s     <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-wl6vj   0/1     ContainerCreating   0          43s     <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-7lg8v   0/1     ContainerCreating   0          43s     <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-7lg8v   1/1     Running             0          45s     10.0.1.83    ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-wl6vj   1/1     Running             0          45s     10.0.1.98    ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-cv6kq   1/1     Running             0          11m     10.0.1.87    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-cv6kq   1/1     Terminating         0          11m     10.0.1.87    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-cv6kq   1/1     Terminating         0          11m     10.0.1.87    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-vn6rn   1/1     Running             0          11m     10.0.1.219   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-vn6rn   1/1     Terminating         0          11m     10.0.1.219   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-vn6rn   1/1     Terminating         0          11m     10.0.1.219   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-zw9v8   0/1     Pending             0          0s      <none>       <none>                      <none>           <none>
spot-test-647b569fd7-zw9v8   0/1     Pending             0          0s      <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-zw9v8   0/1     ContainerCreating   0          0s      <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-9g7rv   0/1     Pending             0          0s      <none>       <none>                      <none>           <none>
spot-test-647b569fd7-9g7rv   0/1     Pending             0          0s      <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-9g7rv   0/1     ContainerCreating   0          0s      <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-cv6kq   0/1     Completed           0          11m     10.0.1.87    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-vn6rn   0/1     Completed           0          11m     10.0.1.219   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-zw9v8   0/1     ContainerCreating   0          0s      <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-9g7rv   0/1     ContainerCreating   0          0s      <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-vn6rn   0/1     Completed           0          11m     10.0.1.219   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-vn6rn   0/1     Completed           0          11m     10.0.1.219   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-cv6kq   0/1     Completed           0          11m     10.0.1.87    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-cv6kq   0/1     Completed           0          11m     10.0.1.87    ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-zw9v8   1/1     Running             0          1s      10.0.1.244   ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-9g7rv   1/1     Running             0          1s      10.0.1.199   ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-jrn4n   1/1     Running             0          11m     10.0.1.215   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-jrn4n   1/1     Terminating         0          11m     10.0.1.215   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-gqzp7   0/1     Pending             0          0s      <none>       <none>                      <none>           <none>
spot-test-647b569fd7-jrn4n   1/1     Terminating         0          11m     10.0.1.215   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-gqzp7   0/1     Pending             0          0s      <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-gqzp7   0/1     ContainerCreating   0          0s      <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-jrn4n   0/1     Completed           0          11m     10.0.1.215   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-jrn4n   0/1     Completed           0          11m     10.0.1.215   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-jrn4n   0/1     Completed           0          11m     10.0.1.215   ip-10-0-1-33.ec2.internal   <none>           <none>
spot-test-647b569fd7-gqzp7   0/1     ContainerCreating   0          1s      <none>       ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-gqzp7   1/1     Running             0          1s      10.0.1.185   ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-7lg8v   1/1     Running             0          109s    10.0.1.83    ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-wl6vj   1/1     Running             0          2m      10.0.1.98    ip-10-0-1-49.ec2.internal   <none>           <none>
spot-test-647b569fd7-zw9v8   1/1     Running             0          78s     10.0.1.244   ip-10-0-1-49.ec2.internal   <none>           <none>
```

Window 4. Get the spot instance ID from command:
```
kubectl get nodes -l karpenter.sh/capacity-type=spot -o json
```

This should show something like:
```
NAME                        STATUS   ROLES    AGE     VERSION
ip-10-0-1-33.ec2.internal   Ready    <none>   6m16s   v1.36.3-eks-cb19647
ip-10-0-1-33.ec2.internal   Ready    <none>   9m12s   v1.36.3-eks-cb19647
ip-10-0-1-33.ec2.internal   Ready    <none>   9m12s   v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   0s      v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   0s      v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   0s      v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   0s      v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   1s      v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   1s      v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   1s      v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   2s      v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   10s     v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   Ready      <none>   14s     v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   Ready      <none>   14s     v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   Ready      <none>   17s     v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   Ready      <none>   17s     v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   Ready      <none>   31s     v1.36.3-eks-cb19647
ip-10-0-1-33.ec2.internal   NotReady   <none>   10m     v1.36.3-eks-cb19647
ip-10-0-1-33.ec2.internal   NotReady   <none>   10m     v1.36.3-eks-cb19647
ip-10-0-1-33.ec2.internal   NotReady   <none>   10m     v1.36.3-eks-cb19647
ip-10-0-1-33.ec2.internal   NotReady   <none>   10m     v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   Ready      <none>   4m7s    v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   Ready      <none>   4m7s    v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   Ready      <none>   4m7s    v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   4m8s    v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   4m8s    v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   4m12s   v1.36.3-eks-cb19647
ip-10-0-1-49.ec2.internal   NotReady   <none>   4m39s   v1.36.3-eks-cb19647
```

8. Delete the deployment pods 

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

9. Cleanup and destroy AWS resources:

```
./terraform_destroy.sh
```