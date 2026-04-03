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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, < 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_policy_json"></a> [assume\_role\_policy\_json](#input\_assume\_role\_policy\_json) | Assume role policy (JSON string). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Role name. | `string` | n/a | yes |
| <a name="input_create_instance_profile"></a> [create\_instance\_profile](#input\_create\_instance\_profile) | Create an IAM instance profile for this role. Default is false for safer shared-module reuse. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Role description. | `string` | `"Managed by OpenTofu"` | no |
| <a name="input_inline_policies_json"></a> [inline\_policies\_json](#input\_inline\_policies\_json) | Map of inline policies (policy\_name => JSON string). | `map(string)` | `{}` | no |
| <a name="input_instance_profile_name"></a> [instance\_profile\_name](#input\_instance\_profile\_name) | Optional instance profile name override. If null, uses role name. | `string` | `null` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | Managed policy ARNs to attach. | `list(string)` | `[]` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | Optional IAM permissions boundary policy ARN. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Role ARN. |
| <a name="output_id"></a> [id](#output\_id) | Role id. |
| <a name="output_instance_profile_arn"></a> [instance\_profile\_arn](#output\_instance\_profile\_arn) | Instance profile ARN (null if not created). |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | Instance profile name (null if not created). |
| <a name="output_name"></a> [name](#output\_name) | Role name. |
| <a name="output_permissions_boundary"></a> [permissions\_boundary](#output\_permissions\_boundary) | Permissions boundary attached to the role (null if not set). |
<!-- END_TF_DOCS -->
