We will perform a bunch of tests in the EKS cluster to see if the EKS addons are installed and access to them is working correctly.  We install the following adds:

1. Pod Identity Agent
2. Amazon Secrets and Configuration Provider (ASCP) & Secrets Store CSI Driver
3. EBS CSI Driver

Then we will test each addon by deploying various K8s objects.  Each yaml file is prefixed with the type of test. Apply the yaml files in each directory to start testing.

First create the production namespace:

```
kubectl apply -f kubernetes-files/production-namespace.yaml
```

Then change into the production namespace so all kubectl commands are applied from there:

```
kubectl config set-context --current --namespace=production
```

## Pod Identity Agent Test 


To test the Pod Identity Agent, we have the file in `read-s3-test`, run the command:

```
kubectl exec -i aws-cli -- aws s3 ls
```

If this doesn't work, delete the pod and recreate it.


## ASCP & Secrets Store CSI Test

To test ASCP & Secrets Store CSI Driver, apply all the files is in the directory `read-secrets-test`.  To test access to the secrets stored in AWS Secrets Manager, run the following commands to list out the files that contain the secrets and to print out the secrets.  

The following is the template for the commands:

```
kubectl exec -i <NGINX_POD_NAME> -n <NAMESPACE> -- ls <MOUNT_PATH>
```

```
kubectl exec -i <NGINX_POD_NAME> -n <NAMESPACE> -- cat <MOUNT_PATH>/<SECRET_NAME>
```

Note: `<MOUNT_PATH>` is the path where the secrets are mounted in the Nginx deployment object with key `mountPath`.


For ours example files, use the commands below.

To list out the files containing secrets (note the two forward slashes //mnt/secrets are to avoid a Git Bash error, on Unix, only a single forward slash is necessary /mnt/secrets):

```
kubectl exec -i deployment/nginx-secure-deployment -- ls //mnt/secrets
```

To print out the actual secret value:

```
kubectl exec -i deployment/nginx-secure-deployment -- cat //mnt/secrets/MY_NGINX_PASSWORD
```

`MY_NGINX_PASSWORD` is coming from `SecretProviderClass`.


## EBS CSI Driver Test


This test is done with files in `ebs-test`.

1. Verify the PVC status (initially, the PVC will be in a Pending state due to `WaitForFirstConsumer`, once the Nginx Pod is scheduled, the status should change to `Bound`):
```
kubectl get pvc ebs-pvc
```

2. Verify the Pod status (it needs to be in the `Running` state):
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

6. Delete all K8s objects with:
```
kubectl delete -f k8s-files
```

7. Verify that the PersistentVolume and PersistentVolumeClaim are still present:
```
kubectl get pv -n production
kubectl get pvc -n production
```

Also check in the AWS EC2 console under Volumes on the left menu that these EBS volumes are still present.  These need to be deleted manually but only the PVC needs to be deleted and PV is deleted automatically:
```
kubectl delete pvc <PVC_NAME>
```