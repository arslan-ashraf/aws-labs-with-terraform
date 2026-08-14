Create a secret in AWS Secrets Manager titled `my-secret` and create a key named `MY_NGINX_PASSWORD` with an arbitrary value.




Install AWS Load Balancer Controller:
```
helm repo add eks https://aws.github.io/eks-charts
```

```
helm repo update eks

```

```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set region=${AWS_REGION} \
  --set vpcId=${VPC_ID} \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller 
```

Verify:
```
 kubectl get all -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```