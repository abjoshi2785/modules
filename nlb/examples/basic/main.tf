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

module "nlb" {
  source = "../.."

  name                = "example-nlb"
  subnet_ids          = ["subnet-0123456789abcdef0", "subnet-abcdef01234567890"]
  vpc_id              = "vpc-0123456789abcdef0"
  listener_port       = 443
  target_port         = 8443
  target_type         = "instance"
  target_instance_ids = ["i-0123456789abcdef0"]
  tags = {
    env         = "dev"
    owner       = "platform-team"
    cost-center = "shared-services"
  }
}
