

```
openssl genrsa -out private_key_for_cloudfront.pem 2048
```


```
openssl rsa -pubout -in private_key_for_cloudfront.pem -out public_key_for_cloudfront.pem
```