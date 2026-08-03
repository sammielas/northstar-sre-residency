provider "aws" {
  region     = var.aws_region
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  s3_use_path_style = true

  endpoints {
    dynamodb = var.floci_endpoint
    ec2      = var.floci_endpoint
    eks      = var.floci_endpoint
    iam      = var.floci_endpoint
    s3       = var.floci_endpoint
    sts      = var.floci_endpoint
  }

  default_tags {
    tags = {
      Project     = "northstar-sre-residency"
      Environment = "development"
      ManagedBy   = "terraform"
      Platform    = "floci"
    }
  }
}
