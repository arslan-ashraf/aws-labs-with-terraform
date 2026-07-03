output "invoke_url" {
  value = "${aws_api_gateway_stage.production_stage.invoke_url}/users"
}