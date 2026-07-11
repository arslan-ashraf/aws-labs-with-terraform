Note: this lab takes about 10 minutes to create all resources and 10 more to destroy all resources.

In this lab, we test the AutoScaling functionality of EC2 instances.  We attach a custom domain to the Application load balancer which points to an AutoScaling Group.  

The EC2 instance(s) run a basic NodeJS application wrapped in a Docker container.  Once the home page is visited, it runs an inefficient algorithm to find a fairly large number.  This is intentional because this task is CPU intensive and its purpose is to raise an EC2 instance's CPU usage to trigger auto scaling.

To test this lab:
1. Run the Terraform config and enter the custom domain name.

2. Once the Terraform config runs to completion, it can still take some time for the instance to install Docker, build the image, and run the container.  This is all in the `user_data.sh` script.  To see if the script has finished running, simply SSH into the instance and run:
```
cat /var/log/cloud-init-output.log
```
If the server is running, then its good to receive requests.

3. Hammer the server with lots of requests, experiment with:

```
n=5
for ((i=1; i<=$n; i++)); do curl -I https://<custom_domain>; done
```