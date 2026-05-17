#!/bin/bash

echo "working"

: <<'COMMENT'

If working with an ubuntu ami, use the following user data script to 
automatically install the aws cli

#!/bin/bash
# Update package list and install dependencies
sudo apt-get update -y
sudo apt-get install -y unzip curl

# Download the official AWS CLI v2 installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip and run the installer
unzip awscliv2.zip
sudo ./aws/install

# Optional: Clean up installation files
rm -rf awscliv2.zip ./aws

COMMENT