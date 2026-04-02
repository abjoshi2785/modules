# iam_role module (OpenTofu)

## What this module does
Creates an IAM Role with:
- Inline policies (map of JSON policy documents)
- Optional managed policy attachments
- Optional permissions boundary
- Optional instance profile (default: disabled for safer shared reuse)

## Resources created
- `aws_iam_role.this`
- `aws_iam_role_policy.inline` (0..N)
- `aws_iam_role_policy_attachment.managed` (0..N)
- `aws_iam_instance_profile.this` (0..1)

## Versioning (module-scoped tags)
Tag format example: `iam_role/v0.3.0`

Consumer pinning example:
```hcl
module "iam_role" {
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//iam_role?ref=iam_role/v0.4.0"
}
```

## Development
- `tofu fmt -recursive`
- `tofu validate`

## Inputs / Outputs

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
