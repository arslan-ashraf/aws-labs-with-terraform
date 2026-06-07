import { STSClient, AssumeRoleCommand } from "@aws-sdk/client-sts";
import { S3Client } from "@aws-sdk/client-s3";
import { createPresignedPost } from "@aws-sdk/s3-presigned-post";

const s3Client = new S3Client({ region: process.env.AWS_REGION });

export const handler = async (event) => {
    console.log("event:", event)
    try {

        // extract the user's IP address from the event object
        const user_ip = event.user_ip
        
        // define your S3 upload parameters
        const bucket_name = process.env.BUCKET_NAME
        
        // this must be the exact name of the file to upload
        const s3_object_key = event.file_to_upload

        const s3Client = new S3Client({ region: "us-east-1" });

        
        // create the Presigned POST with an IP restriction condition
        const { url, fields } = await createPresignedPost(s3Client, {
            Bucket: bucket_name,
            Key: s3_object_key,
            Conditions: [
                // Only allow the upload if the source IP matches the requester
                ["eq", "$x-amz-meta-ip", user_ip], 
                ["content-length-range", 0, 10485760],  // restrict file size up to 10MB
                { "content-type": "application/json" }  // restrict file type
            ],
            Fields: {
              "Content-Type": "application/json",
              "x-amz-meta-ip": user_ip
            },
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


/* USE THIS CODE TO DOWNLOAD AN EXISTING OBJECT IN AN S3 BUCKET

import { S3Client, GetObjectCommand } from "@aws-sdk/s3-client";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

async function generateUserPresignedUrl(userIpAddress) {
  // Initialize standard S3 client using your server's native IAM permissions
  const s3Client = new S3Client({ region: "us-east-1" });

  const command = new GetObjectCommand({
    Bucket: "my-secure-bucket",
    Key: "example-file.pdf",
    // Embed the IP restriction directly into the request parameters
    // AWS automatically signs this condition into the signature query parameter
    "x-amz-condition-IpAddress": {
      "aws:SourceIp": userIpAddress
    }
  });

  // Generate the URL (Valid for 15 minutes)
  const url = await getSignedUrl(s3Client, command, { expiresIn: 900 });
  return url;
}

*/