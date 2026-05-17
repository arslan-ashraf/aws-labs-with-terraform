resource "aws_sqs_queue" "simple_queue" {
  name = "simple_queue"

  visibility_timeout_seconds = 30
  policy = "Optional"
  fifo_queue = "Optional"

  tags = { Name = "simple_queue" }
}