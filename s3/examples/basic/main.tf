terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "s3" {
  source = "../.."

  bucket_name = "replace-me-with-a-globally-unique-bucket-name"

  lifecycle_rules = [
    {
      id              = "expire-logs"
      status          = "Enabled"
      prefix          = "logs/"
      expiration_days = 90
    }
  ]
}
