import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";

const dynamo_db_client = new DynamoDBClient({ region: 'us-east-1' });
const dynamo_db = DynamoDBDocumentClient.from(dynamo_db_client);

async function handler(event) {
    const user_id = event.queryStringParameters.user_id;
    const params = {
        TableName: 'UserData',
        Key: { user_id }
    };

    try {
        const command = new GetCommand(params);
        const { Item } = await dynamo_db.send(command);
        if (Item) {
            return {
                statusCode: 200,
                body: JSON.stringify(Item),
                headers: {'Content-Type': 'application/json'}
            };
        } else {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: "No user data found" }),
                headers: {'Content-Type': 'application/json'}
            };
        }
    } catch (err) {
        console.error("Unable to retrieve data:", err);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Failed to retrieve user data" }),
            headers: {'Content-Type': 'application/json'}
        };
    }
}

export { handler };