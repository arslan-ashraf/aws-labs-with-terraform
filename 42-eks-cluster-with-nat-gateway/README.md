In this lab, we create a VPC with a NAT Gateway in a public subnet and an EKS cluster with two worker nodes in private subnets within that VPC.  The worker nodes will communicate to the EKS control plane as well as out to the internet via the NAT Gateway.

We will perform an S3 list buckets test in the EKS cluster to see if the EKS Pod Identity Agen addon and Pod Identity Association are installed and access to them is working correctly.  

1. Run Terraform with:

```
./terraform_apply.sh
```

2. Connect local kubectl to the EKS cluster using the using the `aws eks update-cubeconfig ...` command found easily in Terraforms output.

3. Create the production namespace:

```
kubectl apply -f 03-kubernetes-files/production-namespace.yaml
```

4. Then change into the production namespace so all kubectl commands are applied from there:

```
kubectl config set-context --current --namespace=production
```

## Pod Identity Agent Test 


5. Test the Pod Identity Agent using the directory in `read-s3-test`, run the commands:

```
kubectl apply -f 03-kubernetes-files/read-s3-test/read-s3-service-account.yaml
```

```
kubectl apply -f 03-kubernetes-files/read-s3-test/aws-cli-pod.yaml
```

```
kubectl exec -i aws-cli -- aws s3 ls
```

If this doesn't work, delete the pod and recreate it.

5. Cleanup:

```
./terraform_destroy.sh
```