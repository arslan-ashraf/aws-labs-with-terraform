Missing:

eks cluster missing security group:
```
vpc_config {
    security_group_ids     = [aws_security_group....id] # missing
    subnet_ids              = ...
    endpoint_private_access = true
    endpoint_public_access  = true
}
```


launch template missing security group:
```
resource "aws_launch_template" "eks_nodes" {
  name = ...

  vpc_security_group_ids = [aws_security_group.....id] # missing
  ...
}
```