This lab uses lab 38 as base and builds on lab 44.  This time we use Pod Disruption Budget to ensure our application running on spot instances has zero downtime.  We will ensure this with EventBridge rules and an SQS queue.

When AWS wants to take back spot instances, it sends messages which we can pick using EventBridge rules and send them to the SQS queue.  Karpenter (during installation) will be configured to poll this queue which it does by default every 10 seconds.

Karpenter requires the IAM permissions which we add in its IAM policy.

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
NAME                       TYPE        CAPACITY     ZONE         NODE
spot-nodepool-4sfj2   	   t3a.small   spot     	us-east-1b   ip-10-0-2-114.e
spot-nodepool-fv8s6   	   t3a.small   spot     	us-east-1b   ip-10-0-2-146.e
```

5. Simulate AWS spot interruption - we will send a message to the SQS queue which will be of the same type that AWS sends when it wants to take back a spot instance:

Get the spot instance ID from command:
```
kubectl get nodes -l karpenter.sh/capacity-type=spot -o json
```

Get the SQS queue URL and send interruption message:
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