In this lab, we harden the security of the EKS cluster by removing all public access of the EKS worker nodes.  Worker nodes will only have access to ECR, S3, EKS control plane, autoscaling, EC2 APIs and more through VPC endpoints.


```
kubectl apply -f eks-test.yaml
```

Now, exec into the Nginx pod:
```
kubectl exec -i deployment/eks-test-nginx -- //bin/sh
```

and print the `index.html` file:
```
cat /usr/share/nginx/html/index.html
```

This should print all of the contents of `index.html` file if everything is working correctly.