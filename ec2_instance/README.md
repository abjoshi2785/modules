# ec2_instance module (OpenTofu)

## What this module does
Creates a single EC2 instance with secure defaults:
- IMDSv2 required by default
- Encrypted root volume by default (gp3, 30GiB)
- Consistent plain-text user_data input
- Optional detailed monitoring, EBS optimization, termination protection, and extra EBS volumes
- Optional instance profile

## Resources created
- `aws_instance.this`

## Versioning (module-scoped tags)
Tag format example: `ec2_instance/v0.3.0`

Consumer pinning example:
```hcl
module "ec2_instance" {
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//terraform/modules/ec2_instance?ref=ec2_instance/v0.4.0"
}
```

## Development
- `tofu fmt -recursive`
- `tofu validate`

## Inputs / Outputs
See `variables.tf` and `outputs.tf`.
