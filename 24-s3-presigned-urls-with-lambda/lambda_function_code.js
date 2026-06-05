import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const handler = async (event) => {
    const s3Client = new S3Client({ region: "us-east-1" });
    
    const bucket_name = "private-bucket-49587sdf90458s3";
    
    // this must be the name of the file to upload and download
    const object_key = "example-file.txt";

    try {
        // Create the command (use PutObjectCommand for file uploads)
        const command = new GetObjectCommand({
            Bucket: bucket_name,
            Key: object_key,
        });

        // Generate the presigned URL
        const presignedUrl = await getSignedUrl(s3Client, command, { 
            expiresIn: 300 // URL expires in 5 minutes (300 seconds)
        });

        return {
            statusCode: 200,
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            body: JSON.stringify({ url: presignedUrl }),
        };
    } catch (error) {
        console.error("Error creating presigned URL", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: "Failed to generate presigned URL" }),
        };
    }
};
