The setting: a Lambda function is created manually using the AWS console.
But behind the scenes AWS will automatically create a CloudWatch log group.
and a role with permissions to write to that log group.  In this Terraform lab,
we import all resources so we can manage them with Terraform.