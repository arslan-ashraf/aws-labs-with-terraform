This lab is a continuation of lab 38.  We install the Load Balancer Controller in the EKS cluster which will provision the AWS Application Load Balancer.  But it does require care when we delete resources.

First we create the EKS cluster along with the Helm installation of the Load Balancer Controller.  Second, we apply the Kubernetes files.  When destroying and cleaning up, we apply the process in reverse because the AWS Load Balancer is created by Kubernetes, not by Terraform.

1. Apply the Terraform config and configure the local machine to connect to EKS cluster, update local kubeconfig using the AWS CLI to point to your new cluster:

```
aws eks update-kubeconfig --region us-east-1 --name example_eks_cluster
```

2. Create the production namespace:

```
kubectl apply -f kubernetes-files/production-namespace.yaml
```

3. Change into the production namespace so all kubectl commands are applied from there:

```
kubectl config set-context --current --namespace=production
```

4. Apply rest of Kubernetes files:

```
kubectl apply -f kubernetes-files/load-balancer-test
```

5. Test the load balancer by visiting the custom domain:

```
curl -s https://arslanashraf.site
```

6. Delete the load balancer:

```
kubectl delete -f kubernetes-files/load-balancer-test
```

7. Terraform destroy.