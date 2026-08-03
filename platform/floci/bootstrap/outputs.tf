output "state_bucket_name" {
  description = "Name of the Terraform state bucket."
  value       = try(aws_s3_bucket.terraform_state[0].bucket, null)
}

output "state_lock_table_name" {
  description = "Name of the Terraform lock table."
  value       = try(aws_dynamodb_table.terraform_locks[0].name, null)
}
