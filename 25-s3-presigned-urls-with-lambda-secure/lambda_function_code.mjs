import { STSClient, AssumeRoleCommand } from "@aws-sdk/client-sts";
import { S3Client } from "@aws-sdk/client-s3";
import { createPresignedPost } from "@aws-sdk/s3-presigned-post";

const s3Client = new S3Client({ region: process.env.AWS_REGION });

export const handler = async (event) => {
    try {

        // extract the user's IP address from the event object
        const user_ip = event.user_ip
        
        // define your S3 upload parameters
        const bucket_name = process.env.BUCKET_NAME
        const bucket_arn = process.env.BUCKET_ARN
        
        // this must be the name of the file to upload and download
        const s3_object_key = event.file_to_upload

        const url_use_permission_role_arn = process.env.PRESIGNED_URL_USE_PERMISSION_ROLE_ARN

        const session_policy = JSON.stringify({
            Version: "2012-10-17",
            Statement: [{
                Effect: "Allow",
                Action: "s3:PutObject", 
                Resource: `${bucket_arn}/*`,
                Condition: {
                    IpAddress: { "aws:SourceIp": `${user_ip}/32` }
                }
            }]
        });

        // assume a local IAM Role (this role just needs s3:PutObject permissions)
        const stsClient = new STSClient({});
        const assumed_role = await stsClient.send(new AssumeRoleCommand({
            RoleArn: url_use_permission_role_arn,
            RoleSessionName: `UploadSession-${Date.now()}`,
            Policy: session_policy // <-- Injects the dynamic IP constraint here
        }));

        // instantiate the S3 Client using the dynamic token
        const s3Client = new S3Client({
            credentials: {
                accessKeyId: assumed_role.Credentials.AccessKeyId,
                secretAccessKey: assumed_role.Credentials.SecretAccessKey,
                sessionToken: assumed_role.Credentials.SessionToken,
            }
        });

        
        // create the Presigned POST with an IP restriction condition
        const { url, fields } = await createPresignedPost(s3Client, {
            Bucket: bucket_name,
            Key: s3_object_key,
            Conditions: [
                // Only allow the upload if the source IP matches the requester
                ["eq", "$x-amz-meta-ip", user_ip], 
                { "ip-address": { "aws:SourceIp": `${user_ip}/32` } },
                ["content-length-range", "0", "10485760"],  // restrict file size up to 10MB
                { "content-type": "application/json" }  // restrict file type
            ],
            Expires: 600, // URL expires in 10 minutes or 600 milliseconds
        });

        return {
            statusCode: 200,
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ url, fields }),
        };
    } catch (err) {
        console.error(err);
        return { statusCode: 500, body: JSON.stringify({ message: "Failed to generate URL" }) };
    }
};