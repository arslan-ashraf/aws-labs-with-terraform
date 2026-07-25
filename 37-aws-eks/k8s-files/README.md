We will perform a bunch of tests in the EKS cluster to see if the EKS addons are installed and access to them is working correctly.  We install the following adds:

1. Pod Identity Agent
2. Amazon Secrets and Configuration Provider & Secrets Store CSI Driver
3. EBS CSI Driver

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

Note: `<MOUNT_PATH>` is the path where the secrets are mounted in the Nginx deployment object with key `mountPath`.


For the example files in current directory, use the commands below.

To list out the files containing secrets:

```
kubectl exec -it deployment/nginx-secure-deployment -n production -- ls /mnt/secrets
```

To print out the actual secret value:

```
kubectl exec -it deployment/nginx-secure-deployment -n production -- cat /mnt/secrets/MY_NGINX_PASSWORD
```

`MY_NGINX_PASSWORD` is coming from `SecretProviderClass`.