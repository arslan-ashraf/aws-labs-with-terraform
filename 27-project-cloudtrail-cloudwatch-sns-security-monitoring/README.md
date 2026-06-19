In this project, the goal is to create a secret in SecretsManager and then monitor every time that secret is accessed and by who.  This is done by CloudTrail which will store its logs in S3.  

Furthermore, we create a CloudWatch log group to send the same CloudTrail logs to a CloudWatch log group.  CloudWatch will also get these logs from the same S3 bucket.  

We also create a CloudWatch alarm that goes off every time anyone accesses the secret.  We want to be notified by email when that alarm goes off which we get from SNS.

The reason we send CloudTrail logs to CloudWatch is because we want to setup an SNS notification and CloudTrail only stores logs for 90 days.  Also log analytics are possible in CloudWatch but we don't explore that in this project.