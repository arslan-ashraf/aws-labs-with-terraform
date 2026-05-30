This lab creates an S3 bucket with a static index.html file uploaded to it.  It also creates an EC2 instance with an Elastic IP attached that installs the Apache Web Server and serves two files index.html and ip.html.

Finally, we also create a CloudFront Distribution with an origin group that serves content from S3 first and if S3 doesn't have the page, then it falls back to serving content from EC2 instance.  CloudFront gets its EC2 domain name from the Elastic IP.

**Note: this lab does not lead to a solution with end-to-end encryption.**  In fact, the load balancer terminates TLS encryption and communication between the load balancer and the backend compute instances is unencrypted.