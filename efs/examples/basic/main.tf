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
  tags = {
    env         = "dev"
    owner       = "platform-team"
    cost-center = "shared-services"
  }
}
