import path from "path"
import fs from "fs/promises";


async function uploadFile(file_to_upload, upload_s3_url, fields) {

  const formData = new FormData();

  Object.entries(fields).forEach(([key, value]) => {
    formData.append(key, value);
  });

  formData.append("file", file_to_upload)
  console.log("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
  console.log(file_to_upload)
  console.log(file_to_upload instanceof File);
  console.log("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

  const uploadResponse = await fetch(upload_s3_url, {
    method: "POST",
    body: formData
  });

  if (!uploadResponse.ok) {
    throw new Error("Upload failed");
  }

  console.log("Upload successful");
}


// get the path of another file relative to the current folder
const file_path = path.join(import.meta.dirname, 'file_to_upload_to_s3.json');

const buffer = await fs.readFile(file_path);

const file_to_upload = new File(
  [buffer],
  "file_to_upload_to_s3.json",
  {
    type: "application/json"
  }
)


let url = "<presigned_upload_url>"
let fields = {
  'Content-Type': 'application/json',
  'x-amz-meta-ip': '<user_ip>',
  bucket: '<s3_bucket_name>',
  'X-Amz-Algorithm': '<hash_algorithm>',
  'X-Amz-Credential': '<temporary_credentials',
  'X-Amz-Date': '<date>',
  'X-Amz-Security-Token': '<security_token',
  key: 'file_to_upload_to_s3.json',
  Policy: '<policy>',
  'X-Amz-Signature': '<hash_signature>'
}

await uploadFile(file_to_upload, url, fields);