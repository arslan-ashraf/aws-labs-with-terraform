This is a continuation of the previous lab.  S3 presigned URLs do not have a built-in feature to expire after a single use, nor do they dynamically track IP addresses on their own.

To ensure one time use of the URL, requires the application backend to record a user's actions in a database.  S3 also does not guarantee that only the user who requested the presigned URL is the one who is allowed to use it.

However, we can enforce other restrictions such as how long the presigned URL is active for, the size range that the uploaded file must have, the file type, the file name among other things.  We accomplish this in the Lambda function's code with the JavaScript SDK.


To generate an S3 presigned URL, invoke the Lambda function using the command:

```
 aws lambda invoke \
 --function-name generate-presigned-s3-url \
 --cli-binary-format raw-in-base64-out \
 --payload file://lambda_input.json \
 lambda_output.json
```

The file `lambda_input.json` must contain the following object with the user's IP address filled in:
```
{
	"file_to_upload": "file_to_upload_to_s3.json",
	"user_ip": "<user_up>"
}
```

To test the presigned URL:

This will create a file lambda_output.json that contains the presigned URL and the "fields" object.  To parse all of the Lambda functions output, execute the file `extract-presigned-url.js` with the correct settings in the console.

Then copy the URL and the fields object into the file `use-presigned-url.js` with the correct settings and execute it.