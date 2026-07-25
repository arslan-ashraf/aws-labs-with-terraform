We will perform a bunch of tests in the EKS cluster to see if the EKS addons are installed and access to them is working correctly.  We install the following adds:

1. Pod Identity Agent
2. Amazon Secrets and Configuration Provider (ASCP) & Secrets Store CSI Driver
3. EBS CSI Driver

Then we will test each addon by deploying various K8s objects.  Each yaml file is prefixed Apply the yaml files with:

```
kubectl apply
```

To test the Pod Identity Agent, we have the file `s3-test-aws-cli-pod.yaml`, run the command:

```
kubectl exec -it aws-cli -- aws s3 ls
```

If this doesn't work, delete the pod and recreate it.


To test ASCP & Secrets Store CSI Driver, we access the secrets stored in AWS Secrets Manager.  Run the following commands to list out the files that contain the secrets and to print out the secrets:

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