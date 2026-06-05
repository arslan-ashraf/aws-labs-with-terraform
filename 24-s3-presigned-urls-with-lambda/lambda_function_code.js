import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const handler = async (event) => {
    const s3Client = new S3Client({ region: "us-east-1" });
    
    const bucketName = "your-s3-bucket-name";
    const objectKey = "example-file.pdf";

    try {
        // Create the command (use PutObjectCommand for file uploads)
        const command = new GetObjectCommand({
            Bucket: bucketName,
            Key: objectKey,
        });

        // Generate the presigned URL
        const presignedUrl = await getSignedUrl(s3Client, command, { 
            expiresIn: 3600 // URL expires in 1 hour (in seconds)
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
