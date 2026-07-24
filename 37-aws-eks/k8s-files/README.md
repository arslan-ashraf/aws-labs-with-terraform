Apply the yaml files and run the command:

```
kubectl exec -it aws-cli -- aws s3 ls
```

to test if the aws-cli pod is able to list S3 buckets.  If this doesn't work, delete the pod and recreate it.


To test the secret store in AWS Secrets Manager stored in the Nginx pods, use the following command to list out the files that contain the secrets and to print out the secrets, use the following commands:

```
kubectl exec -it <NGINX_POD_NAME> -n <NAMESPACE> -- ls <MOUNT_PATH>
```

```
kubectl exec -it <NGINX_POD_NAME> -n <NAMESPACE> -- cat <MOUNT_PATH>/<SECRET_NAME>
```

```
kubectl exec -it <NGINX_POD_NAME> -n production -- ls /mnt/secrets
```

```
kubectl exec -it <NGINX_POD_NAME> -n production -- cat /mnt/secrets/my-nginx-secret
```

Note: `/mnt/secrets` is the path where the secrets are mounted in the Nginx deployment object.

To print out the actual secret value:

