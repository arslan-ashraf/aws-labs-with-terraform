In this lab, we run a basic Python server on an EC2 instance that gets API secrets from SecretsManager.  The example here only serves to show what is possible.  Ordinarily, these secrets would be something like database credentials or API keys to an external service such as Stripe or a call to an LLM.

Here, we use IAM credentials to merely list S3 buckets.  This is for demonstration only and is not a best practice.  The appropriate way for an EC2 or AWS compute to obtain access to other AWS services is through IAM roles.

To implement this lab, follow these steps:

1. In the AWS console, create IAM access key credentials and create a secret in SecretsManager that stores those credentials.  

2. To run this Terraform lab, copy the secret's ARN.

3. SSH into the EC2 instance and copy all the files in `basic-python-app` folder into the EC2 instance and install pip, v-env, create and activate the virtual environment, install Python packages, and finally run the Python server:

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

5. Force delete the secret in SecretsManager:
```
aws secretsmanager delete-secret \
    --secret-id <secret_name_or_ARN> \
    --force-delete-without-recovery
```

6. Delete IAM credentials.