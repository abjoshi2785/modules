# asg module (OpenTofu)

## What this module does
Creates:
- Launch Template
- Auto Scaling Group

Production behaviors:
- IMDSv2 required by default
- Encrypted root volume by default
- Instance refresh enabled by default so AMI/user_data changes roll instances
- Preconditions enforce valid size relationships
- Consistent plain-text user_data input, encoded internally for the launch template

## Resources created
- `aws_launch_template.this`
- `aws_autoscaling_group.this`

## Versioning (module-scoped tags)
Tag format example: `asg/v0.3.0`

Consumer pinning example:
```hcl
module "asg" {
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//asg?ref=asg/v0.4.0"
}
```

## Development
- `tofu fmt -recursive`
- `tofu validate`

## Inputs / Outputs

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
