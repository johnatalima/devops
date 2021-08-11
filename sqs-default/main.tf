provider "aws" {
  region = "eu-central-1"
}


resource "aws_sqs_queue" "terraform_queue" {
  name                      = var.name
  delay_seconds             = var.delay_seconds
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  policy                    = jsonencode(var.policy)
  tags = jsonencode(var.tags)
}
