This is a continuation of the previous lab.  S3 presigned URLs do not have a built-in feature to expire after a single use, nor do they dynamically track IP addresses on their own.  

To ensure one time use of the URL requires a database that records a user's actions.  To guarantee that only the user who requested the presigned URL is the one who is allowed to use it, we use the user's IP address.


To generate an S3 presigned URL, invoke the Lambda function using the command:

```
 aws lambda invoke \
 --function-name generate-presigned-s3-url \
 --cli-binary-format raw-in-base64-out \
 --payload file://lambda_input.json \
 lambda_output.json
```
This will create a file lambda_output.json that contains the presigned URL. 

