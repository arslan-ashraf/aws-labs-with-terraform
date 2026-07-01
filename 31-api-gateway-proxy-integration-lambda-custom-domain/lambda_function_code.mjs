import { 
    DynamoDBClient, 
    ListTablesCommand,
    DescribeTableCommand 
} from "@aws-sdk/client-dynamodb";

import { 
    DynamoDBDocumentClient, 
    GetCommand 
} from "@aws-sdk/lib-dynamodb";

const dynamo_db_client = new DynamoDBClient({ region: 'us-east-1' });
const dynamo_db = DynamoDBDocumentClient.from(dynamo_db_client);

async function handler(event) {

    const query_string_params = event.queryStringParameters

    if (query_string_params != null){

        let users_table = process.env.USERS_TABLE

        let _user_id = query_string_params.user_id

        try {

            // dynamo_db_params format
            // const dynamo_db_params = {
            //     TableName: "YourTableName",
            //     Key: {
            //       PartitionKeyName: "PrimaryKeyValue",
            //       SortKeyName: "SortKeyValue"  // comment out if your table does not use a sort key
            //     }
            // }

            let dynamo_db_params = {
                TableName: users_table,
                Key: {
                    user_id: String(_user_id)
                }
            }

            const dynamo_db_command = new GetCommand(dynamo_db_params)
            const data_item = await dynamo_db.send(dynamo_db_command)

            if (data_item) {
                return {
                    statusCode: 200,
                    body: JSON.stringify(data_item),
                    headers: {'Content-Type': 'application/json'}
                }
            } else {
                return {
                    statusCode: 404,
                    body: JSON.stringify({ 
                        statusCode: 404,
                        message: "not found",
                        table: users_table,
                        query_string_params: query_string_params,
                        user_id: _user_id,
                        user_id_type: typeof(_user_id),
                        event: event
                    }),
                    headers: {'Content-Type': 'application/json'}
                }
            }
        } catch (error) {

            console.error("Unable to retrieve user data:", error);

            return {
                statusCode: 500,
                body: JSON.stringify({
                    statusCode: 500,
                    message: "Failed to retrieve user data",
                    error: error 
                }),
                headers: {'Content-Type': 'application/json'}
            };
        }
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