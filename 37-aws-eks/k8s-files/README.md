Apply the yaml files and run the command:

```
kubectl exec -it aws-cli -- aws s3 ls
```

to test if the aws-cli pod is able to list S3 buckets.  If this doesn't work, delete the pod and recreate it.


To test the secret store in AWS Secrets Manager stored in the Nginx pods, use the following command to list out the files that contain the secrets

```
kubectl exec -it <NGINX_POD_NAME> -- ls /mnt/secrets
```


kubectl exec -it <NGINX_POD_NAME> -- cat /mnt/secrets/my-nginx-app-secret