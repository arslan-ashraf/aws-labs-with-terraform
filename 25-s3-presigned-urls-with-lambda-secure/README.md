This is a continuation of the previous lab.  S3 presigned URLs do not have a built-in feature to expire after a single use, nor do they dynamically track IP addresses on their own.  

To ensure one time use of the URL requires a database that records a user's actions.

```
 aws lambda invoke \
 --function-name example-function \
 --cli-binary-format raw-in-base64-out \
 --payload file://lambda_input.json \
 lambda_output.json
```


```
curl -X PUT \
-H "Content-Type: application/json" \
--data-binary "@./file_to_upload_to_s3.json" \
"PRESIGNED_URL_HERE"
```


curl -v "https://your-bucket-name.s3.amazonaws.com/" \
-F "key=uploads/user-123/profile.jpg" \
-F "AWSAccessKeyId=AKIA..." \
-F "x-amz-security-token=IQoJ..." \
-F "policy=eyJleHA..." \
-F "signature=base64_encoded_signature" \
-F "content-type=image/jpeg" \
-F "file=@/path/to/your/local/file.jpg"