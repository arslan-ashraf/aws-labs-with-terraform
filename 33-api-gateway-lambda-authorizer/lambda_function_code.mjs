async function handler(event) {

    const query_string_params = event.queryStringParameters

    if (query_string_params != null){

        
        
    } else {

        return {
            statusCode: 200,
            body: JSON.stringify({ 
                message: "queryStringParameters is null", 
                invocation: "Success",
                event: event
            }),
            headers: {'Content-Type': 'application/json'}
        };

    }

}

export { handler };