# converts the javascript file into a zip file as AWS requires either a zip 
# or docker image for the lambda function 
data "archive_file" "zipping_function_code" {
  type = "zip"
  source_file = "./index.js"
  output_path = "lambda_js_code_zipped.zip"
}

# this lambda function is not to be created but imported as below
resource "aws_lambda_function" "example_lambda_function" {
  
  function_name = "manually-created-lambda"
  handler = "index.handler"    # entrypoint function in javascript file
  role = aws_iam_role.lambda_execution_role.arn
  runtime = "Node.js 22.x"
  memory_size = 128   # in MegaBytes
  timeout = 10        # in seconds

  # hash of the source code package file, it is used to trigger updates
  # when the lambda function's source code locally changes
  source_code_hash = data.archive_file.zipping_function_code.output_base64sha256
  
  logging_config {
    log_format = "Text"
    log_group = aws_cloudwatch_log_group.log_group_for_lambda.name
  }

  tags = { Name = "example_lambda_function" }
  
  # sample vpc configuration
  # vpc_config {
  #   subnet_ids                  = [aws_subnet.example_subnet1.id, aws_subnet.example_subnet2.id]
  #   security_group_ids          = [aws_security_group.sg_for_lambda.id]
  #   ipv6_allowed_for_dual_stack = true # Enable IPv6 support
  # }

}


# imports the manually created lambda function into the Terraform resource
# defined above
import {
  to = aws_lambda_function.example_lambda_function
  from = "manually-created-lambda"
}

resource "aws_lambda_function_url" "example_lambda_url" {
  function_name = aws_lambda_function.example_lambda_function.function_name
  authorization_type = "NONE"
}