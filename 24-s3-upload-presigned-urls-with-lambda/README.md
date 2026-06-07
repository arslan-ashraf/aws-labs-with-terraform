The purpose of this lab is to generate S3 presigned URLs for uploading files directly to S3.

This lab creates a Lambda function, a CloudWatch log group for the Lambda function to send logs to, an S3 bucket and IAM permissions.  To generate an S3 presigned URL, invoke the Lambda function using the command:

```
 aws lambda invoke \
 --function-name generate-presigned-s3-url \
 --cli-binary-format raw-in-base64-out \
 --payload file://lambda_input.json \
 lambda_output.json
```
This will create a file lambda_output.json that contains the presigned URL. 

**Note** that these URLs do not have a built-in feature to expire after a single use, nor do they dynamically track IP addresses on their own.  They can be used indefinitely until expiration by anyone.

Also, any file can be uploaded of any size upto 5 GBs which is enforced by S3, as long as the file type remains the one specified in the JavaScript SDK PutObjectCommand class.

To test the presigned URL, use the curl command in the file use-presigned-url.sh.  Just run the executable with the url inserted.

```
./use-presigned-url.sh
```