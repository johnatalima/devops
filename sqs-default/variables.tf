variable name {
    type        = string
    default     = "sqs-tf"
    description = "(Optional) The name of the queue. Queue names must be made up of only uppercase and lowercase 
                    ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 80 characters long"
  }

variable delay_seconds {
  type        = number
  default     = 90
  description = "(Optional) The time in seconds that the delivery of all messages in the queue will be delayed.
                An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds."
}

variable max_message_size {
  type        = number
  default     = 2048
  description = "(Optional) The limit of how many bytes a message can contain before Amazon SQS rejects it.
                An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). The default for this attribute is 262144 (256 KiB)."
}

variable message_retention_seconds {
  type        = number
  default     = 86400
  description = "(Optional) The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days).
                The default for this attribute is 345600 (4 days)."
}

variable receive_wait_time_seconds {
  type        = number
  default     = 10
  description = "(Optional) The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning.
                An integer from 0 to 20 (seconds). The default for this attribute is 0, meaning that the call will return immediately."
}

variable policy {
  type        = map
  default     = {}
  description = "(Optional) The JSON policy for the SQS queue."
}

variable tags {
  type        = map
  default     = {}
  description = "(Optional) A map of tags to assign to the queue"
}
