#!/usr/bin/bash

<< 'COMMENT'
curl -X PUT \
-H "Content-Type: application/json" \
--data-binary "@./file_to_upload_to_s3.json" \
"PRESIGNED_URL_HERE"
COMMENT