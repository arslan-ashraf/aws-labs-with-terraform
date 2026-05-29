This lab creates an S3 bucket with a static index.html file uploaded to it.  It also creates an EC2 instance that installs the Apache Web Server and serves two files index.html and ip.html.

Finally, we also create a CloudFront Distribution with an origin group that serves content from S3 first and if S3 doesn't have the page, then it falls back to serving content from EC2 instance.