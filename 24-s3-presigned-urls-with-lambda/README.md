This lab creates a Lambda function, a CloudWatch log group for the Lambda function to send logs to, an S3 bucket and IAM permissions.  The Lambda function when invoked using the command

```
 aws lambda invoke \
 --function-name generate-presigned-s3-url \
 --cli-binary-format raw-in-base64-out \
 --payload file://lambda_input.json \
 lambda_output.json
```

generates an S3 presigned URL. Note that these URLs do not have a built-in feature to expire after a single use, nor do they dynamically track IP addresses on their own.  They can be used indefinitely until expiration by anyone.

To test the presigned URL, use the curl command in the file use-presigned-url.sh.  Just run the executable with the url inserted.

```
./use-presigned-url.sh
```