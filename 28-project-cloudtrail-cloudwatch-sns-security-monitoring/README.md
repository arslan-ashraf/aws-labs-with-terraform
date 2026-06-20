In this project, the goal is to create a secret in SecretsManager and then monitor every time that secret is accessed and by who.  This is done by CloudTrail which will store its logs in S3.  

Furthermore, we create a CloudWatch log group to send the same CloudTrail logs to a CloudWatch log group.  CloudWatch retrieves these logs from the same S3 bucket and not directly from CloudTrail.

We also create a CloudWatch alarm that goes off every time anyone accesses the secret.  We want to be notified by email when that alarm goes off which we get from SNS.

The reason we send CloudTrail logs to CloudWatch is because we want to setup an SNS notification and CloudTrail only stores logs for 90 days.  Also log analytics are possible in CloudWatch but we don't explore that in this project.

To setup this project, first create a secret in SecretsManager manually using the AWS console.  We don't to manage secrets with Terraform because they can't just be created and deleted arbitrarily.  Normally when you delete a secret, it doesn't get deleted but stays dormant for 7 to 30 days.

Then apply this Terraform configuration and view the secret which can be done on the AWS console or using the AWS CLI.

To get the CloudTrail log delivery times:
```
aws cloudtrail get-trail-status --name secret_accessed_trail
```

To force delete a secret key in SecretsManager:
```
aws secretsmanager delete-secret \
    --secret-id <secret_name_or_ARN> \
    --force-delete-without-recovery
```