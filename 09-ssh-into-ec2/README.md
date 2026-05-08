To connect to an ec2 using ssh:

Step 1: generate ssh keys
```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/key-for-ec2-connection
```

Step 2: create a Terraform object and upload public key to AWS
```
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}

```

Step 3: ssh into the ec2 instace using the private key, -i is for "identity"
```
ssh -i key-for-ec2-connection <remote_username>@<remote_ip_address>
```