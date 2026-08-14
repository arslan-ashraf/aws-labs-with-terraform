In this lab, we harden the security of the EKS cluster by removing all public access of the EKS worker nodes.  Worker nodes will only have access to ECR, S3, EKS control plane, autoscaling, EC2 APIs and more through VPC endpoints.

We test this labs as follows:

1. Run Terraform.

2. Connect local kubectl to the EKS cluster using the using the `aws eks update-cubeconfig ...` command found easily in Terraforms output.

3. Run the Docker script to create the Docker image and push it to ECR:

```
./run-docker.sh
```

4. Create the Kubernetes resources:

```
kubectl apply -f eks-test.yaml
```

4. Now, exec into the Nginx pod:

```
kubectl exec -i deployment/eks-test-nginx -- //bin/sh
```

and print the `index.html` file:
```
cat /usr/share/nginx/html/index.html
```

This should print all of the contents of `index.html` file if everything is working correctly.