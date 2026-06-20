This lab is a continuation of the previous one.  The only difference is that instead of SNS sending an email notification in response to CPU utilization exceeding the desired threshold, SNS will instead trigger a Lambda function.

First, confirm the SNS topic subscription by copying the link in the button, (don't click the button, it automatically unsubscribes) and pasting it into the SNS topic.

Then, SSH into the EC2 instance, create and launch a Python script (`cpu_spike.py`) inside the instance to spike its CPU usage.  We can then see that indeed the Lambda function ran in the Lambda console under monitor tab.

To connect to an ec2 using ssh using the private key:

Note: -i is for "identity"
```
ssh -i .ssh/key-for-ec2-connection <remote_username>@<remote_ip_address>
```