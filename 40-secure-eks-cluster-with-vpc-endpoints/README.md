eks cluster missing security group:
```
vpc_config {
    security_group_ids     = [aws_security_group.eks_cluster.id] # missing
    subnet_ids              = ...
    endpoint_private_access = true
    endpoint_public_access  = true
}
```


launch template missing security group:
```
resource "aws_launch_template" "eks_nodes" {
  name = ...

  vpc_security_group_ids = [aws_security_group.eks_nodes.id] # missing
  ...
}
```


```
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
```



```
kubectl exec -i $(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}') -- sh -c "echo 'EKS Cluster up and running!' > /usr/share/nginx/html/index.html"
```

Now, exec into the Nginx pod:
```
kubectl exec -i deployment/eks-test-nginx -- //bin/sh
```

and print the `index.html` file:
```
cat /usr/share/nginx/html/index.html
```

This should print "EKS Cluster up and running!" if everything is working correctly.