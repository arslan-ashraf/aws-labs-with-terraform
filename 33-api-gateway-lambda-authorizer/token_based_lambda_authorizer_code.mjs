function handler(event) {

    let iam_policy_response = null

    let auth_token = event.authorizationToken

    if (auth_token == "user_123"){
        iam_policy_response = generatePolicy(auth_token, 'Allow', event.methodArn)
    } else {
        iam_policy_response = generatePolicy(auth_token, 'Deny', event.methodArn)
    }

    return iam_policy_response
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

export { handler }