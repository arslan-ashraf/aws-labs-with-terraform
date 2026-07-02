async function handler(event) {

    return {
        statusCode: 200,
        body: JSON.stringify({ 
            lambda_invocation: "Success",
            message: "Backend Lambda successfully invoked", 
            event: event
        }),
        headers: {'Content-Type': 'application/json'}
    }

}

export { handler }