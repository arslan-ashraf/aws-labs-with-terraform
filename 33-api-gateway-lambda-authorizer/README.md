

curl -H "authorizationToken: user_123" https://p7b1cztmei.execute-api.us-east-1.amazonaws.com/production/users

1. Run the Terraform lab.

2. Go to the DynamoDB console and manually add a user with user_id equal to 456 and any other example fields.

3. Visit the custom domain as follows:
`<custom_domain>` or `<cloudfront_url>`.

4. Enter the user ID 456 in the search bar and click the button on the page.

Here is what the front page looks like:
<!-- ![Alt Text](.png) -->

After retrieving user data:
<!-- ![Alt Text](.png) -->