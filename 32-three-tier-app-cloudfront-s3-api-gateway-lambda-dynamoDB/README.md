This lab creates the resource `aws_api_gateway_domain_name` which takes more than 10 minutes to create.

In this lab, we create a three tier web application.  We start with a CloudFront distribution that will sit in front an S3 bucket which will host the static files, including a JavaScript file that will make a `fetch()` call to CloudFront which is configured to have a second origin, the API Gateway.

 API Gateway that sits in front of a Lambda function.  Further, we create an A record in the Route53 public zone that maps the custom domain name to the CloudDFront distribution.

We also create a DynamoDB table which holds a `users_table`.  The goal is to use the custom domain to visit a web page that CloudFront will deliver.  On the page, there is a button that once clicked, will send a call to CloudFront with a query string which should read the API Gateway which then calls the Lambda function, which in turn will parse query string and send the appropriate GET request to DynamoDB.

1. In the JavaScript file, replace `<custom_domain>` with the actual domain.

2. Run the Terraform lab.

3. Go to the DynamoDB console and manually add a user with user_id equal to 123 and any other example fields.

4. Visit the custom domain as follows:
`<custom_domain>` or `<cloudfront_url>`.

In this lab, there should be no errors.  However, if after any modification, there are errors when visiting the site such as:

{"message":"Missing Authentication Token"} 

It means the resource path given by `aws_api_gateway_resource` is broken.

{"message": "Internal server error"} 

This error means the API Gateway successfully matched the route but any of the following could be an issue:
- Malformed Lambda IAM resource permissions, couldn't invoke the Lambda function because the URL link doesn't match where the Lambda can be invoked from
- Lambda threw an exception that wasn't handled