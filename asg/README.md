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
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_additional_ebs_volumes"></a> [additional\_ebs\_volumes](#input\_additional\_ebs\_volumes) | Additional EBS volumes to attach through the launch template. | <pre>list(object({<br>    device_name           = string<br>    volume_size           = number<br>    volume_type           = optional(string, "gp3")<br>    encrypted             = optional(bool, true)<br>    kms_key_id            = optional(string)<br>    delete_on_termination = optional(bool, true)<br>    iops                  = optional(number)<br>    throughput            = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_capacity_reservation_preference"></a> [capacity\_reservation\_preference](#input\_capacity\_reservation\_preference) | Capacity reservation preference for launched instances. | `string` | `"open"` | no |
| <a name="input_capacity_reservation_target_id"></a> [capacity\_reservation\_target\_id](#input\_capacity\_reservation\_target\_id) | Optional capacity reservation ID when targeting a specific reservation. | `string` | `null` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | n/a | `number` | `1` | no |
| <a name="input_detailed_monitoring"></a> [detailed\_monitoring](#input\_detailed\_monitoring) | Enable detailed CloudWatch monitoring in the launch template. | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | Enable EBS optimization when supported by the instance type. | `bool` | `false` | no |
| <a name="input_enable_instance_refresh"></a> [enable\_instance\_refresh](#input\_enable\_instance\_refresh) | Enable ASG instance refresh on launch template changes by default. | `bool` | `true` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Seconds to ignore failing health checks after instance launch. | `number` | `300` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | n/a | `string` | `"EC2"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | Optional instance profile name. Set null to skip. | `string` | `null` | no |
| <a name="input_imds_hop_limit"></a> [imds\_hop\_limit](#input\_imds\_hop\_limit) | IMDS hop limit. | `number` | `1` | no |
| <a name="input_imds_require_v2"></a> [imds\_require\_v2](#input\_imds\_require\_v2) | Require IMDSv2 (recommended). | `bool` | `true` | no |
| <a name="input_instance_refresh_instance_warmup"></a> [instance\_refresh\_instance\_warmup](#input\_instance\_refresh\_instance\_warmup) | Warmup time (seconds) before considering an instance healthy. | `number` | `300` | no |
| <a name="input_instance_refresh_min_healthy_percentage"></a> [instance\_refresh\_min\_healthy\_percentage](#input\_instance\_refresh\_min\_healthy\_percentage) | Minimum healthy percentage during refresh. | `number` | `50` | no |
| <a name="input_instance_refresh_triggers"></a> [instance\_refresh\_triggers](#input\_instance\_refresh\_triggers) | Triggers that cause an instance refresh. | `list(string)` | <pre>[<br>  "launch_template"<br>]</pre> | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | n/a | `string` | `null` | no |
| <a name="input_launch_template_update_default_version"></a> [launch\_template\_update\_default\_version](#input\_launch\_template\_update\_default\_version) | Update the launch template default version when changes are made. | `bool` | `true` | no |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | Launch template version for the ASG. Use $Latest, $Default, or a specific version number. | `string` | `"$Latest"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | n/a | `number` | `2` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | n/a | `number` | `1` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | Optional placement group name for the launch template. | `string` | `null` | no |
| <a name="input_root_device_name"></a> [root\_device\_name](#input\_root\_device\_name) | Root device name for block mapping. | `string` | `"/dev/xvda"` | no |
| <a name="input_root_kms_key_id"></a> [root\_kms\_key\_id](#input\_root\_kms\_key\_id) | Optional KMS key id/arn for root volume encryption. | `string` | `null` | no |
| <a name="input_root_volume_encrypted"></a> [root\_volume\_encrypted](#input\_root\_volume\_encrypted) | Encrypt root volume. | `bool` | `true` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root volume size in GiB. | `number` | `30` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | Root volume type. | `string` | `"gp3"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply. | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | n/a | `list(string)` | `[]` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Optional plain-text user\_data. The module base64-encodes it for the launch template. Changing it updates the launch template and may trigger instance refresh depending on instance\_refresh\_triggers. | `string` | `null` | no |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | Maximum time Terraform waits for ASG capacity stabilization. | `string` | `"15m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | Auto Scaling Group ARN. |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | Auto Scaling Group name. |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | Availability zones used by the Auto Scaling Group. |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | Launch template ID. |
| <a name="output_launch_template_latest_version"></a> [launch\_template\_latest\_version](#output\_launch\_template\_latest\_version) | Latest version of the launch template. |
<!-- END_TF_DOCS -->
