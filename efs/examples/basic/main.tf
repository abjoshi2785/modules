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

module "efs" {
  source = "../.."

  name               = "example-efs"
  subnet_ids         = ["subnet-0123456789abcdef0"]
  security_group_ids = ["sg-0123456789abcdef0"]

  file_system_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Deny"
      Principal = { AWS = "*" }
      Action    = "*"
      Resource  = "*"
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    }]
  })

  access_points = {
    app = {
      posix_user = { uid = 1000, gid = 1000 }
      root_directory = {
        path = "/app"
        creation_info = {
          owner_uid   = 1000
          owner_gid   = 1000
          permissions = "755"
        }
      }
    }
  }

  tags = {
    env         = "dev"
    owner       = "platform-team"
    cost-center = "shared-services"
  }
}
