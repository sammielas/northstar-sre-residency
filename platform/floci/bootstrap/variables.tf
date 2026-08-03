variable "aws_region" {
  description = "AWS Region used by the Floci environment."
  type        = string
  default     = "us-east-1"
}

variable "floci_endpoint" {
  description = "Floci AWS-compatible API endpoint."
  type        = string
  default     = "http://localhost:4566"
}

variable "state_bucket_name" {
  description = "S3 bucket used to store Terraform state."
  type        = string
  default     = "northstar-terraform-state"
}

variable "state_lock_table_name" {
  description = "DynamoDB table used for Terraform state locking."
  type        = string
  default     = "northstar-terraform-locks"
}

variable "enable_state_backend_creation" {
  description = "Controls whether the state bucket and lock table are created."
  type        = bool
  default     = false
}
