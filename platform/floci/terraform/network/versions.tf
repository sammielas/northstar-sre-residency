terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.57"
    }
  }

  backend "s3" {
    bucket         = "northstar-terraform-state"
    key            = "floci/network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "northstar-terraform-locks"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}
