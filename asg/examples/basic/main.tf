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

module "asg" {
  source = "../.."

  name               = "example-asg"
  ami_id             = "ami-0123456789abcdef0"
  subnet_ids         = ["subnet-0123456789abcdef0"]
  security_group_ids = ["sg-0123456789abcdef0"]
  target_group_arns  = ["arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/example/1234567890abcdef"]
  user_data          = <<-EOT
    #!/bin/bash
    echo hello > /tmp/hello.txt
  EOT
}
