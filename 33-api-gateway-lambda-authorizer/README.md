In this lab, we test the API Gateway's Authorizer functionality which authorizes a user request using an `authorizationToken` which is hard coded to be `user_123` for simplicity.

The idea is that the API Gateway is invoked with the header `authorizationToken: user_123` as follows:

```
curl -H "authorizationToken: user_123" https://<api_gateway_id>.execute-api.us-east-1.amazonaws.com/production/users
```

This URL can be found in the terminal once the Terraform config is run to completion.

The API Gateway then forwards this to the `authorizer_lambda` function which always returns an IAM policy and does a trivial check against the `authorizationToken` to see if it equals `user_123`, if it does it return

1. Run the Terraform lab.

2. Go to the DynamoDB console and manually add a user with user_id equal to 456 and any other example fields.

3. Visit the custom domain as follows:
`<custom_domain>` or `<cloudfront_url>`.

4. Enter the user ID 456 in the search bar and click the button on the page.

Here is what the front page looks like:
<!-- ![Alt Text](.png) -->

After retrieving user data:
<!-- ![Alt Text](.png) -->