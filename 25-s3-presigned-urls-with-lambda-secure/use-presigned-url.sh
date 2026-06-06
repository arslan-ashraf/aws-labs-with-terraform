#!/usr/bin/bash

curl -v "https://private-bucket-49587sdf90458s3.s3.us-east-1.amazonaws.com/" \
-F "key=..."  \
-F "X-Amz-Algorithm=..."  \
-F "X-Amz-Credential=..."  \
-F "X-Amz-Date=..."  \
-F "Policy=..."  \
-F "X-Amz-Signature=..."  \
-F "x-amz-meta-ip=..." \
-F "bucket=..."  \
-F "X-Amz-Security-Token=..."  \
-F "file=@./file_to_upload_to_s3.json"