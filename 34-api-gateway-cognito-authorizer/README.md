In this lab, we create a Cognito user pool which is a database of users and their login credentials.  We have an API Gateway which will authenticate a user's request with Cognito and if successful, pass on that request to the `backend_lambda` function.


1. Run the Terraform lab.

2. Visit the API Gateway's invoke URL as above with the correct header.

Here is a successful looks like:
![Alt Text](33-terraform-lab.png)