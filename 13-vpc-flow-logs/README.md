To connect to an ec2 using ssh:

Step 1: generate ssh keys and set owner read only permissions on private key
```
ssh-keygen -t rsa -b 4096 -f .ssh/key-for-ec2-connection
chmod 400 .ssh/key-for-ec2-connection
```

Step 2: create a Terraform object and upload public key to AWS and 
add key_name field to aws_instance object
```
resource "aws_key_pair" "deployer" {
  key_name   = "key-for-ec2-connection"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}

resource "aws_instance" "ec2_instance" {
  ami           = "..."
  instance_type = "..."
  key_name      = "key-for-ec2-connection"
}
```

Step 3: ssh into the ec2 instace using the private key, -i is for "identity"
```
ssh -i .ssh/key-for-ec2-connection <remote_username>@<remote_ip_address>
```