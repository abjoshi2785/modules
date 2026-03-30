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

module "ec2_instance" {
  source = "../.."

  name               = "example-ec2"
  ami_id             = "ami-0123456789abcdef0"
  subnet_id          = "subnet-0123456789abcdef0"
  security_group_ids = ["sg-0123456789abcdef0"]
  user_data          = <<-EOT
    #!/bin/bash
    echo hello > /tmp/hello.txt
  EOT
}
