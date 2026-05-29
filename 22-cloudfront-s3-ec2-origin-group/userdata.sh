#!/bin/bash

sudo apt-get update -y
sudo apt-get install apache2 -y


# Create a custom HTML page using the instance metadata for context
cat <<EOF > /var/www/html/ip.html
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
        <h1>Apache Web Server is running Successfully!</h1>
        <p>This page was automatically deployed via EC2 User Data on Ubuntu.</p>
        <p class="ip-address"><strong>IP Address: $(hostname -i | cut -d" " -f1)</strong></p>
    </div>
</body>
</html>
EOF

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Static Website</title>
</head>
<body>
    <p style="font-size: 50px;">This page can be served by S3 and EC2.</p>
    
</body>
</html>
EOF

sudo systemctl restart apache2
sudo systemctl enable apache2