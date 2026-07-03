In this lab, we test the API Gateway's Authorizer functionality which authorizes a user request using an `authorizationToken` which is hard coded to be `user_123` for simplicity.

The idea is that the API Gateway is invoked with the header `authorizationToken: user_123` as follows:

```
curl -H "authorizationToken: user_123" https://<api_gateway_id>.execute-api.us-east-1.amazonaws.com/production/users
```

This URL can be found in the terminal once the Terraform config is run to completion.

The API Gateway then forwards this to the `authorizer_lambda` function which always returns an IAM policy and does a trivial check against the `authorizationToken` to see if it equals `user_123`.  If it does, then it returns an `Effect = 'Allow'` back to the API Gateway.

The API Gateway then inspects the return IAM policy and if it does have an `Effect = 'Allow'`, then the API Gateway forwards the request to the `backend_lambda` which returns an arbitrary example response.

1. Run the Terraform lab.

2. Visit the API Gateway's invoke URL as above with the correct header.

Here is a successful looks like:
<!-- ![Alt Text](.png) -->