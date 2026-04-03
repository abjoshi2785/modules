# efs module (OpenTofu)

## What this module does
Creates an EFS file system and one mount target per subnet.

Also supports optional performance mode and throughput mode controls.

Includes cost-control default:
- Lifecycle policy transitions data to EFS Infrequent Access (IA) (default: AFTER_30_DAYS)

## Resources created
- `aws_efs_file_system.this`
- `aws_efs_mount_target.this` (one per subnet)

## Versioning (module-scoped tags)
Tag format example: `efs/v0.3.0`

Consumer pinning example:
```hcl
module "efs" {
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//efs?ref=efs/v0.4.0"
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
| [aws_efs_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets for mount targets (one per AZ recommended). | `list(string)` | n/a | yes |
| <a name="input_access_points"></a> [access\_points](#input\_access\_points) | Map of EFS access points to create. | <pre>map(object({<br>    posix_user = optional(object({<br>      uid            = number<br>      gid            = number<br>      secondary_gids = optional(list(number))<br>    }))<br>    root_directory = optional(object({<br>      path = string<br>      creation_info = optional(object({<br>        owner_uid   = number<br>        owner_gid   = number<br>        permissions = string<br>      }))<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | n/a | `bool` | `true` | no |
| <a name="input_file_system_policy_json"></a> [file\_system\_policy\_json](#input\_file\_system\_policy\_json) | Optional EFS file system policy JSON string. | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Optional KMS key ARN for EFS encryption. | `string` | `null` | no |
| <a name="input_performance_mode"></a> [performance\_mode](#input\_performance\_mode) | EFS performance mode. | `string` | `"generalPurpose"` | no |
| <a name="input_provisioned_throughput_in_mibps"></a> [provisioned\_throughput\_in\_mibps](#input\_provisioned\_throughput\_in\_mibps) | Provisioned throughput in MiB/s when throughput\_mode is provisioned. | `number` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security groups for mount targets. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply. | `map(string)` | `{}` | no |
| <a name="input_throughput_mode"></a> [throughput\_mode](#input\_throughput\_mode) | EFS throughput mode. | `string` | `"bursting"` | no |
| <a name="input_transition_to_ia"></a> [transition\_to\_ia](#input\_transition\_to\_ia) | Transition files to EFS IA to control costs. | `string` | `"AFTER_30_DAYS"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_point_arns"></a> [access\_point\_arns](#output\_access\_point\_arns) | Map of access point name to ARN. |
| <a name="output_access_point_ids"></a> [access\_point\_ids](#output\_access\_point\_ids) | Map of access point name to ID. |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | EFS DNS name for mounting. |
| <a name="output_file_system_arn"></a> [file\_system\_arn](#output\_file\_system\_arn) | EFS file system ARN. |
| <a name="output_file_system_id"></a> [file\_system\_id](#output\_file\_system\_id) | EFS file system ID. |
| <a name="output_mount_target_ids"></a> [mount\_target\_ids](#output\_mount\_target\_ids) | Map of subnet ID to mount target ID. |
<!-- END_TF_DOCS -->
