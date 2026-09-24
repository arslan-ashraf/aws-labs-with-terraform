This lab starts with lab 10.  We create one EC2 instance in a private subnet and another one in a public subnet all using loops.  

Furthermore, security groups are attached to each EC2 instance to allow remote SSH login to the instance in the public subnet, which can reach out to the internet and also has rules to ping and to SSH into the private EC2 instance.

The instance in the private subnet can only be accessed by other instances in the same VPC through PING and SSH.

We add a `user_data.sh` script to the public EC2 instance which builds two Docker images, one for a basic Python application and the other for running ansible.

All of the Ansible code is in the `user_data.sh` script.

The public EC2 instance will serve as the Ansible control node and the private instance will serve as the Ansible managed node.


1. Run the Terraform lab.

2. SSH into the EC2 instance in the public subnet and ping the EC2 instance in the private subnet using its private IP address.

3. After going into the public instance using SSH, read the cloud init logs to see the installation of Docker and the two Docker images that were built and run.

```
cat /var/log/cloud-init-output.log
```

4. Visit the web application running on the public EC2 instance using its public IP address.

5. In the public EC2 instance's terminal, in the file `inventory/production_servers.yaml`, add the private IP address of the private instance on line `<server_IP_address>`.

6. Create file `key-for-ec2-connection` and add the private key into to SSH into the private EC2 instance for running Ansible.

7. Rebuild the Docker image, run it, and execute the playbook:

```
sudo docker build -t my-ansible-core -f ansible_dockerfile
```

Test if ansible is installed correctly:
```
sudo docker run --rm -it \
  -v $(pwd):/ansible \
  my-ansible-core
```

Ping private EC2 instance:
```
docker run --rm -it \
  -v $(pwd):/ansible \
  -v "/key-for-ec2-connection:/keys/key-for-ec2-connection:ro" \
  my-ansible-core \
  ansible backend-servers -m ping
```

Execute the playbook:
```
docker run --rm -it \
  -v $(pwd):/ansible \
  -v "/key-for-ec2-connection:/keys/key-for-ec2-connection:ro" \
  my-ansible-core \
ansible-playbook playbook.yaml
```