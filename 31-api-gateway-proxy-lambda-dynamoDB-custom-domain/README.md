This lab creates the resource `aws_api_gateway_domain_name` which takes more than 10 minutes to create.

In this lab, we create an API Gateway that sits in front of a Lambda function.  Further, we create an A record in the Route53 public zone that maps the custom domain name to the API Gateway.

We also create a DynamoDB table which holds a `users_table`.  The goal is to use the custom domain with a query string which the Lambda function will parse the query string and send the appropriate GET request to DynamoDB.

1. Run the Terraform lab.

2. Go to the DynamoDB console and manually add a user with user_id equal to 123 and any other example fields.

3. Visit the custom domain with the query string as follows:
`<custom_domain>/users?user_id=123` or `<api_gateway_url>/users?user_id=123`.

In this lab, there should be no errors.  However, if after any modification, there are errors when visiting the site such as:

{"message":"Missing Authentication Token"} 

It means the resource path given by `aws_api_gateway_resource` is broken.

{"message": "Internal server error"} 

This error means the API Gateway successfully matched the route but any of the following could be an issue:
- Malformed Lambda IAM resource permissions, couldn't invoke the Lambda function because the URL link doesn't match where the Lambda can be invoked from
- Lambda threw an exception that wasn't handled