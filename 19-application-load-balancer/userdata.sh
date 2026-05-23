#!/bin/bash

# Update the package repository
apt-get update -y

# Install Nginx
apt-get install nginx -y

# Start Nginx service
systemctl start nginx

# Enable Nginx to run automatically on system boot
systemctl enable nginx

# Create a custom HTML page using the instance metadata for context
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My EC2 Instance</title>
    <style>
        body { font-family: sans-serif; text-align: center; margin-top: 10%; background-color: #f4f6f9; color: #333; }
        h1 { color: #232f3e; }
        .ip-address { font-size: 50px; }
        .card { background: white; padding: 20px; border-radius: 8px; display: inline-block; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    <div class="card">
        <h1>Nginx is Running Successfully!</h1>
        <p>This page was automatically deployed via EC2 User Data on Ubuntu.</p>
        <p class="ip-address"><strong>IP Address: $(hostname -l | cut -d" " -f1)</strong></p>
    </div>
</body>
</html>
EOF