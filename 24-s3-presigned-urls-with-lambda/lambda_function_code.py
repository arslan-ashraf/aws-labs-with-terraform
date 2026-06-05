import os
import boto3
import json
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')
BUCKET_NAME = os.environ['BUCKET_NAME']

def lambda_handler(event, context):
    # Parse object key and target operation from the incoming request body
    body = json.loads(event.get('body', '{}'))
    object_key = body.get('key')
    operation = body.get('operation', 'get_object') # Defaults to download ('get_object')
    
    if not object_key:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing file "key" parameter'})
        }

    try:
        # Generate the presigned URL valid for 15 minutes (900 seconds)
        response = s3_client.generate_presigned_url(
            ClientMethod=operation, # 'get_object' for download or 'put_object' for upload
            Params={'Bucket': BUCKET_NAME, 'Key': object_key},
            ExpiresIn=900 
        )
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

    return {
        'statusCode': 200,
        'body': json.dumps({'presigned_url': response})
    }
