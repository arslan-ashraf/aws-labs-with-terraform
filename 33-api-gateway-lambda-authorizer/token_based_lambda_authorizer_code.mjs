function handler(event) {

    console.log("#".repeat(50))
    console.log(event)
    console.log("#".repeat(50))

    let auth_token = event.AuthorizationToken
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

export { handler }