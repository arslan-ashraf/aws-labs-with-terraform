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