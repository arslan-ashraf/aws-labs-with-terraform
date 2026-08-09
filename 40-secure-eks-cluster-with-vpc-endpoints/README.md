Missing:

eks cluster security group:
```
vpc_config {
    security_group_ids     = [aws_security_group....id] # missing
    subnet_ids              = ...
    endpoint_private_access = true
    endpoint_public_access  = true
}
```