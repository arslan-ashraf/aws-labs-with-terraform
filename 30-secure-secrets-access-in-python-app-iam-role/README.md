This lab is a continuation of the previous lab.  We run a basic Python server on an EC2 instance that accesses S3.  Unlike the previous lab, we don't use any IAM user whose credentials are in SecretsManager.  Instead, we employ the AWS best practice of using an IAM role to give the EC2 instance temporary credentials to access S3.


To implement this lab, follow these steps:

1. To run this Terraform lab.

2. SSH into the EC2 instance and copy the four files in `basic-python-app` folder into the EC2 instance.

3. Now install pip, v-env, create and activate the virtual environment, install Python packages, and finally run the Python server.  For demonstration, there are two options:
    a) Run the shell script `./setup.sh`.
    b) Run all the commands in the shell script one by one as listed below.

```
sudo apt update && sudo apt install python3-pip python3-venv python3-full -y
```

```
python3 -m venv .venv
```

```
source .venv/bin/activate
```

Install Python packages:
```
pip3 install -r requirements.txt
```

Run the Python server:
```
python3 app.py
```

4. Test the app by visiting the URL: <EC2_public_IP>:8000