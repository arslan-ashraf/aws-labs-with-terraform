We will perform a bunch of tests in the EKS cluster to see if the EKS addons are installed and access to them is working correctly.  We install the following adds:

1. Pod Identity Agent
2. Amazon Secrets and Configuration Provider (ASCP) & Secrets Store CSI Driver
3. EBS CSI Driver

###############################################################
################# Pod Identity Agent Test #####################
###############################################################

Then we will test each addon by deploying various K8s objects.  Each yaml file is prefixed Apply the yaml files with:

```
kubectl apply
```

To test the Pod Identity Agent, we have the file `s3-test-aws-cli-pod.yaml`, run the command:

```
kubectl exec -it aws-cli -- aws s3 ls
```

If this doesn't work, delete the pod and recreate it.


###############################################################
############## ASCP & Secrets Store CSI Test ##################
###############################################################


To test ASCP & Secrets Store CSI Driver, we have files prefixed with `secrets-manager-test`.  To test access to the secrets stored in AWS Secrets Manager, run the following commands to list out the files that contain the secrets and to print out the secrets:

```
kubectl exec -it <NGINX_POD_NAME> -n <NAMESPACE> -- ls <MOUNT_PATH>
```

```
kubectl exec -it <NGINX_POD_NAME> -n <NAMESPACE> -- cat <MOUNT_PATH>/<SECRET_NAME>
```

Note: `<MOUNT_PATH>` is the path where the secrets are mounted in the Nginx deployment object with key `mountPath`.


For ours example files, use the commands below.

To list out the files containing secrets:

```
kubectl exec -it deployment/nginx-secure-deployment -n production -- ls /mnt/secrets
```

To print out the actual secret value:

```
kubectl exec -it deployment/nginx-secure-deployment -n production -- cat /mnt/secrets/MY_NGINX_PASSWORD
```

`MY_NGINX_PASSWORD` is coming from `SecretProviderClass`.


To test 

1. Verify the PVC status (initially, the PVC will be in a Pending state due to WaitForFirstConsumer, once the Nginx Pod is scheduled, the status should change to Bound):
```
kubectl get pvc ebs-pvc
```

2. Verify the Pod status (it needs to be in the Running state):
```
kubectl get pods -l app=nginx
```

3. Test data persistence (create a file inside the mounted EBS directory):
```
kubectl exec -it $(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}') -- sh -c "echo 'EBS Working' > /usr/share/nginx/html/index.html"
```

This should print "EBS Working" if EBS has correctly been provisioned.

4. Test if the data persists even after deleting the pod.  Delete the pod and K8s Deployment will automatically create another one:
```
kubectl delete pod -l app=nginx
```

5.  Once the new pod spins up, test if data has remained persisted:
```
kubectl exec -it $(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}') -- cat /usr/share/nginx/html/index.html
```

This should also print "EBS Working".