/*
A simple token-based authorizer example to demonstrate how to use an 
authorization token to allow or deny a request. In this example, the 
caller named 'user' is allowed to invoke a request if the 
client-supplied token value is 'allow'. The caller is not allowed to 
invoke the request if the token value is 'deny'. If the token value 
is 'unauthorized' or an empty string, the authorizer function returns 
an HTTP 401 status code. For any other token value, the authorizer 
returns an HTTP 500 status code. Note that token values are case-sensitive.
*/

export const handler =  function(event, context, callback) {
    let auth_token = event.authorizationToken
    if (auth_token == "user_123"){
        generatePolicy(auth_token, 'Allow', event.methodArn)
    } else {
        generatePolicy(auth_token, 'Deny', event.methodArn)
    }
}

// helper function to generate the IAM policy
function generatePolicy(principalId, effect, resource) {
    let authResponse = {}
    
    authResponse.principalId = principalId

    if (effect && resource) {
        let policyDocument = {}
        policyDocument.Version = '2012-10-17' 
        policyDocument.Statement = []
        let statementOne = {}
        statementOne.Action = 'execute-api:Invoke' 
        statementOne.Effect = effect
        statementOne.Resource = resource
        policyDocument.Statement[0] = statementOne
        authResponse.policyDocument = policyDocument
    }
    
    return authResponse
}