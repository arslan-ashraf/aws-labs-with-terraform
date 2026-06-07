let api_response = {
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },

  // actual body here returned from the Lambda function
  "body": "{\"url\":\"https:// ... }"  
}


// 1. Parse the inner body string
let upload_data = JSON.parse(api_response.body);

// 2. Destructure the URL and Fields
let { url, fields } = upload_data;

console.log("Upload URL:\n", url, "\n\n\n");

// Example: Accessing a specific field like the key
console.log("fields:\n", fields);