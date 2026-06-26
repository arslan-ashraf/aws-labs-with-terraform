In this lab, we have a CloudFront distribution that sits in front of S3.  But S3 is not accessible through CloudFront.  Instead we, the backend, in this case the Python script `generate_cloudfront_presigned_url.py` generates a presigned URL that only the requesting user can access. 

This is achieved by ensuring that the signature takes the requesting user's IP address into account.  Note that this is not the same as S3 presigned urls.

The generated URL is a CloudFront URL and CloudFront is the one serving the content and hence can verify signatures, ensuring that only the verified IP address can access the URL within its valid time.

However, CloudFront may see the user's IPv4 address or the user's IPv6 address.  So in the application code, we need to verify this.

To run this lab:

1. Generate public and private keys:
```
openssl genrsa -out private_key_for_cloudfront.pem 2048
```

```
openssl rsa -pubout -in private_key_for_cloudfront.pem -out public_key_for_cloudfront.pem
```

2. Run Terraform:

3. Run the Python script:
```
python generate_cloudfront_presigned_url.py
```