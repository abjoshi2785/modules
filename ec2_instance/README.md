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
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//ec2_instance?ref=ec2_instance/v0.4.0"
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
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, < 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID. | `string` | n/a | yes |
| <a name="input_additional_ebs_volumes"></a> [additional\_ebs\_volumes](#input\_additional\_ebs\_volumes) | Additional EBS volumes to attach at launch. | <pre>list(object({<br/>    device_name           = string<br/>    volume_size           = number<br/>    volume_type           = optional(string, "gp3")<br/>    encrypted             = optional(bool, true)<br/>    kms_key_id            = optional(string)<br/>    delete_on_termination = optional(bool, true)<br/>    iops                  = optional(number)<br/>    throughput            = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_associate_public_ip"></a> [associate\_public\_ip](#input\_associate\_public\_ip) | Associate public IP. | `bool` | `false` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Optional availability zone override. | `string` | `null` | no |
| <a name="input_capacity_reservation_preference"></a> [capacity\_reservation\_preference](#input\_capacity\_reservation\_preference) | Capacity reservation preference. | `string` | `"open"` | no |
| <a name="input_capacity_reservation_target_id"></a> [capacity\_reservation\_target\_id](#input\_capacity\_reservation\_target\_id) | Optional capacity reservation ID when targeting a specific reservation. | `string` | `null` | no |
| <a name="input_detailed_monitoring"></a> [detailed\_monitoring](#input\_detailed\_monitoring) | Enable detailed CloudWatch monitoring. | `bool` | `true` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | Enable termination protection for the instance. | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | Enable EBS optimization when supported by the instance type. | `bool` | `true` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | Optional instance profile name. | `string` | `null` | no |
| <a name="input_imds_hop_limit"></a> [imds\_hop\_limit](#input\_imds\_hop\_limit) | IMDS hop limit. | `number` | `2` | no |
| <a name="input_imds_require_v2"></a> [imds\_require\_v2](#input\_imds\_require\_v2) | Require IMDSv2 (recommended). | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type. | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Optional key pair name. | `string` | `null` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | Optional placement group name. | `string` | `null` | no |
| <a name="input_root_kms_key_id"></a> [root\_kms\_key\_id](#input\_root\_kms\_key\_id) | Optional KMS key id/arn for root volume encryption. | `string` | `null` | no |
| <a name="input_root_volume_encrypted"></a> [root\_volume\_encrypted](#input\_root\_volume\_encrypted) | Encrypt root volume. | `bool` | `true` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root volume size in GiB. | `number` | `30` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | Root volume type. | `string` | `"gp3"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security group IDs. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply. | `map(string)` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | Instance tenancy. | `string` | `"default"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Optional plain-text user\_data. Set user\_data\_replace\_on\_change=true when replacements are desired on changes. | `string` | `null` | no |
| <a name="input_user_data_replace_on_change"></a> [user\_data\_replace\_on\_change](#input\_user\_data\_replace\_on\_change) | Whether changes to user\_data should force replacement. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | n/a |
<!-- END_TF_DOCS -->
