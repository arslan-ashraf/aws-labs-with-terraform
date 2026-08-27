resource "aws_sqs_queue" "simple_queue" {
  name = "simple_queue"

  visibility_timeout_seconds = 30
  fifo_queue                 = false
  # policy                   = "Optional"

  tags = { Name = "simple_queue" }
}