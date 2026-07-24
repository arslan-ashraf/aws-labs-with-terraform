Apply the yaml files and run the command:

```
kubectl exec -it aws-cli -- aws s3 ls
```

to test if the aws-cli pod is able to list S3 buckets.  If this doesn't work, delete the pod and recreate it.