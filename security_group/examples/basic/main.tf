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

module "security_group" {
  source = "../.."

  name   = "example-sg"
  vpc_id = "vpc-0123456789abcdef0"

  ingress_rules = {
    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "Example HTTPS access"
    }
  }
  tags = {
    env         = "dev"
    owner       = "platform-team"
    cost-center = "shared-services"
  }
}
