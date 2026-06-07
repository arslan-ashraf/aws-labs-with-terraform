import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const handler = async (event) => {
    const s3Client = new S3Client({ region: "us-east-1" });
    
    const bucket_name = process.env.BUCKET_NAME
    
    // this must be the name of the file to upload and download
    const object_key = event.file_to_upload

    try {
        // create command for uploads (PutObjectCommand for file uploads)
        const put_object_command = new PutObjectCommand({
            Bucket: bucket_name,
            Key: object_key,
            ContentType: "application/json"
        });

        // Generate the presigned URL
        const presignedUrl = await getSignedUrl(s3Client, put_object_command, { 
            expiresIn: 300 // URL expires in 5 minutes (300 seconds)
        });

        console.log("Presigned url generated successfully!")

        return {
            statusCode: 200,
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"  // allows anyone to use it
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
