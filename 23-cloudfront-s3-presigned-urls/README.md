In this lab, we have a CloudFront distribution that sits in front of S3.  But S3 is not accessible through CloudFront.  Instead we, the backend, in this case the Python script `generate_cloudfront_presigned_url.py` generates a presigned URL that only the requesting user can access. 

This is achieved by ensuring that the signature takes the requesting user's IP address into account.  Note that this is not the same as S3 presigned urls.

```
openssl genrsa -out private_key_for_cloudfront.pem 2048
```


```
openssl rsa -pubout -in private_key_for_cloudfront.pem -out public_key_for_cloudfront.pem
```