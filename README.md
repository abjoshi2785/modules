# Terraform / OpenTofu AWS Modules

This repository contains a set of reusable, production-grade Terraform / OpenTofu modules for PROS.

These modules provide a consistent, validated, and secure foundation for provisioning infrastructure across environments. They are designed to reduce duplication, enforce organizational standards, and accelerate delivery.

---

## Overview

The modules in this repository are built with the following principles:

* **Consistency** across environments and teams
* **Fail-fast validation** to catch errors during `validate`
* **Secure-by-default configurations**
* **Extensibility without forcing rigid abstractions**
* **Compatibility with enterprise requirements**

---

## Available Modules

<!-- BEGIN_MODULE_INDEX -->
* `asg` – Creates:,Launch Template Auto Scaling Group,Production behaviors: IMDSv2 required by default,Encrypted root volume by default Instance refresh enabled by default so AMI/user_data changes roll instances,Preconditions enforce valid size relationships Consistent plain-text user_data input, encoded internally for the launch template
* `ec2_instance` – Creates a single EC2 instance with secure defaults:,IMDSv2 required by default Encrypted root volume by default (gp3, 30GiB),Consistent plain-text user_data input Optional detailed monitoring, EBS optimization, termination protection, and extra EBS volumes,Optional instance profile
* `efs` – Creates an EFS file system and one mount target per subnet.,Also supports optional performance mode and throughput mode controls. Includes cost-control default:,Lifecycle policy transitions data to EFS Infrequent Access (IA) (default: AFTER_30_DAYS)
* `iam_role` – Creates an IAM Role with:,Inline policies (map of JSON policy documents) Optional managed policy attachments,Optional permissions boundary Optional instance profile (default: disabled for safer shared reuse)
* `nlb` – Creates a Network Load Balancer (NLB) with:,Configurable listener and target group protocol One listener,One target group Optional target attachments for `instance` or `ip`,Optional health check overrides Production behaviors:,Target group name includes a random suffix to avoid name collisions on replacement `random_id` uses keepers so name changes when replacement-relevant inputs change,Target group uses `create_before_destroy` Cross-input validations reduce invalid combinations
* `s3` – Creates an S3 bucket with production defaults:,Encryption (SSE-S3 or SSE-KMS) Public access block,Ownership controls (default: BucketOwnerEnforced) Optional bucket policy,Optional server access logging Optional lifecycle rules with transitions, multipart cleanup, and stronger validation
* `security_group` – Creates an AWS Security Group and a set of ingress/egress rules.,Designed for shared use across teams: Uses `name_prefix` + `create_before_destroy` to avoid name-collision failures during replacement.,Rules are maps keyed by stable names, so diffs are reviewable and rule reordering doesn't cause churn. Includes rule-level validations to reduce invalid combinations.
<!-- END_MODULE_INDEX -->

Each module includes:

* `main.tf`
* `variables.tf`
* `outputs.tf`
* `versions.tf`
* `examples/basic`

---

## Repository Structure

```
s3/
iam_role/
security_group/
ec2_instance/
efs/
asg/
nlb/
```

---

## Key Features

### 1. Organizational Tag Enforcement

All modules require a standard set of tags:

```hcl
tags = {
  env         = "dev"
  owner       = "team-name"
  cost-center = "shared-services"
}
```

This ensures:

* cost allocation
* ownership tracking
* environment separation

---

### 2. Strong Input Validation

Modules include validation to fail early:

* type constraints
* regex validation
* JSON validation (IAM policies)
* cross-field validation

This prevents invalid configurations from reaching `apply`.

---

### 3. IAM Permissions Boundary Support

IAM roles support optional permissions boundaries:

```hcl
permissions_boundary = "arn:aws:iam::123456789012:policy/example-boundary"
```

This enables compliance with enterprise security controls.

---

### 4. Resource Timeouts

Critical resources include explicit timeout configurations:

* Network Load Balancer
* EFS
* Auto Scaling Group

This improves reliability during slow or retry-heavy AWS operations.

---

### 5. Hardened Storage Configuration

EC2 and ASG modules support additional EBS volumes with validation:

* valid volume types enforced
* `iops` required for `io1` / `io2`
* `throughput` only for `gp3`

---

### 6. NLB Guardrails

The NLB module includes:

* protocol compatibility validation
* health check validation
* target type enforcement (instance vs IP)
* TLS certificate validation

---

## Example Usage

Example using the EC2 module:

```hcl
module "ec2_instance" {
  source = "git::https://github.com/<org>/<repo>.git//ec2_instance"

  name               = "example-ec2"
  ami_id             = "ami-0123456789abcdef0"
  subnet_id          = "subnet-0123456789abcdef0"
  security_group_ids = ["sg-0123456789abcdef0"]

  tags = {
    env         = "dev"
    owner       = "platform-team"
    cost-center = "shared-services"
  }
}
```

Each module contains a working example under:

```
examples/basic/
```

---

## CI Validation

Modules are validated using:

* `tofu fmt`
* `tofu init -backend=false`
* `tofu validate`
* `tflint`
* `checkov`

All modules and examples must pass these checks.

---

## Usage Guidelines

* Do not bypass required tags
* Use module examples as a starting point
* Prefer extending modules via inputs instead of forking
* Validate changes locally before committing

---

## Limitations

* Modules are designed as a baseline, not a full platform abstraction
* Some advanced configurations may require extension
* Not all edge cases are enforced via validation

---

## Future Improvements

Potential enhancements include:

* module versioning and release automation
* stricter IAM guardrail enforcement
* expanded S3 lifecycle capabilities
* observability integrations

---

## Generated Module Documentation

<!-- BEGIN_COMBINED_MODULE_DOCS -->
### asg

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
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 5.0, < 6.0 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 5.0, < 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami_id](#input_ami_id) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input_name) | n/a | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_additional_ebs_volumes"></a> [additional_ebs_volumes](#input_additional_ebs_volumes) | Additional EBS volumes to attach through the launch template. | <pre>list(object({<br>    device_name           = string<br>    volume_size           = number<br>    volume_type           = optional(string, "gp3")<br>    encrypted             = optional(bool, true)<br>    kms_key_id            = optional(string)<br>    delete_on_termination = optional(bool, true)<br>    iops                  = optional(number)<br>    throughput            = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_capacity_reservation_preference"></a> [capacity_reservation_preference](#input_capacity_reservation_preference) | Capacity reservation preference for launched instances. | `string` | `"open"` | no |
| <a name="input_capacity_reservation_target_id"></a> [capacity_reservation_target_id](#input_capacity_reservation_target_id) | Optional capacity reservation ID when targeting a specific reservation. | `string` | `null` | no |
| <a name="input_desired_capacity"></a> [desired_capacity](#input_desired_capacity) | n/a | `number` | `1` | no |
| <a name="input_detailed_monitoring"></a> [detailed_monitoring](#input_detailed_monitoring) | Enable detailed CloudWatch monitoring in the launch template. | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs_optimized](#input_ebs_optimized) | Enable EBS optimization when supported by the instance type. | `bool` | `false` | no |
| <a name="input_enable_instance_refresh"></a> [enable_instance_refresh](#input_enable_instance_refresh) | Enable ASG instance refresh on launch template changes by default. | `bool` | `true` | no |
| <a name="input_health_check_grace_period"></a> [health_check_grace_period](#input_health_check_grace_period) | Seconds to ignore failing health checks after instance launch. | `number` | `300` | no |
| <a name="input_health_check_type"></a> [health_check_type](#input_health_check_type) | n/a | `string` | `"EC2"` | no |
| <a name="input_iam_instance_profile"></a> [iam_instance_profile](#input_iam_instance_profile) | Optional instance profile name. Set null to skip. | `string` | `null` | no |
| <a name="input_imds_hop_limit"></a> [imds_hop_limit](#input_imds_hop_limit) | IMDS hop limit. | `number` | `1` | no |
| <a name="input_imds_require_v2"></a> [imds_require_v2](#input_imds_require_v2) | Require IMDSv2 (recommended). | `bool` | `true` | no |
| <a name="input_instance_refresh_instance_warmup"></a> [instance_refresh_instance_warmup](#input_instance_refresh_instance_warmup) | Warmup time (seconds) before considering an instance healthy. | `number` | `300` | no |
| <a name="input_instance_refresh_min_healthy_percentage"></a> [instance_refresh_min_healthy_percentage](#input_instance_refresh_min_healthy_percentage) | Minimum healthy percentage during refresh. | `number` | `50` | no |
| <a name="input_instance_refresh_triggers"></a> [instance_refresh_triggers](#input_instance_refresh_triggers) | Triggers that cause an instance refresh. | `list(string)` | <pre>[<br>  "launch_template"<br>]</pre> | no |
| <a name="input_instance_type"></a> [instance_type](#input_instance_type) | n/a | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key_name](#input_key_name) | n/a | `string` | `null` | no |
| <a name="input_launch_template_update_default_version"></a> [launch_template_update_default_version](#input_launch_template_update_default_version) | Update the launch template default version when changes are made. | `bool` | `true` | no |
| <a name="input_max_size"></a> [max_size](#input_max_size) | n/a | `number` | `2` | no |
| <a name="input_min_size"></a> [min_size](#input_min_size) | n/a | `number` | `1` | no |
| <a name="input_placement_group"></a> [placement_group](#input_placement_group) | Optional placement group name for the launch template. | `string` | `null` | no |
| <a name="input_root_device_name"></a> [root_device_name](#input_root_device_name) | Root device name for block mapping. | `string` | `"/dev/xvda"` | no |
| <a name="input_root_kms_key_id"></a> [root_kms_key_id](#input_root_kms_key_id) | Optional KMS key id/arn for root volume encryption. | `string` | `null` | no |
| <a name="input_root_volume_encrypted"></a> [root_volume_encrypted](#input_root_volume_encrypted) | Encrypt root volume. | `bool` | `true` | no |
| <a name="input_root_volume_size"></a> [root_volume_size](#input_root_volume_size) | Root volume size in GiB. | `number` | `30` | no |
| <a name="input_root_volume_type"></a> [root_volume_type](#input_root_volume_type) | Root volume type. | `string` | `"gp3"` | no |
| <a name="input_security_group_ids"></a> [security_group_ids](#input_security_group_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply. | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target_group_arns](#input_target_group_arns) | n/a | `list(string)` | `[]` | no |
| <a name="input_user_data"></a> [user_data](#input_user_data) | Optional plain-text user_data. The module base64-encodes it for the launch template. Changing it updates the launch template and may trigger instance refresh depending on instance_refresh_triggers. | `string` | `null` | no |
| <a name="input_wait_for_capacity_timeout"></a> [wait_for_capacity_timeout](#input_wait_for_capacity_timeout) | Maximum time Terraform waits for ASG capacity stabilization. | `string` | `"15m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_name"></a> [asg_name](#output_asg_name) | Autoscaling group name. |
| <a name="output_launch_template_id"></a> [launch_template_id](#output_launch_template_id) | Launch template id. |
<!-- END_TF_DOCS -->

---

### ec2_instance

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
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 5.0, < 6.0 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 5.0, < 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami_id](#input_ami_id) | AMI ID. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input_name) | n/a | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id) | Subnet ID. | `string` | n/a | yes |
| <a name="input_additional_ebs_volumes"></a> [additional_ebs_volumes](#input_additional_ebs_volumes) | Additional EBS volumes to attach at launch. | <pre>list(object({<br>    device_name           = string<br>    volume_size           = number<br>    volume_type           = optional(string, "gp3")<br>    encrypted             = optional(bool, true)<br>    kms_key_id            = optional(string)<br>    delete_on_termination = optional(bool, true)<br>    iops                  = optional(number)<br>    throughput            = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_associate_public_ip"></a> [associate_public_ip](#input_associate_public_ip) | Associate public IP. | `bool` | `false` | no |
| <a name="input_availability_zone"></a> [availability_zone](#input_availability_zone) | Optional availability zone override. | `string` | `null` | no |
| <a name="input_capacity_reservation_preference"></a> [capacity_reservation_preference](#input_capacity_reservation_preference) | Capacity reservation preference. | `string` | `"open"` | no |
| <a name="input_capacity_reservation_target_id"></a> [capacity_reservation_target_id](#input_capacity_reservation_target_id) | Optional capacity reservation ID when targeting a specific reservation. | `string` | `null` | no |
| <a name="input_detailed_monitoring"></a> [detailed_monitoring](#input_detailed_monitoring) | Enable detailed CloudWatch monitoring. | `bool` | `true` | no |
| <a name="input_disable_api_termination"></a> [disable_api_termination](#input_disable_api_termination) | Enable termination protection for the instance. | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs_optimized](#input_ebs_optimized) | Enable EBS optimization when supported by the instance type. | `bool` | `true` | no |
| <a name="input_iam_instance_profile"></a> [iam_instance_profile](#input_iam_instance_profile) | Optional instance profile name. | `string` | `null` | no |
| <a name="input_imds_hop_limit"></a> [imds_hop_limit](#input_imds_hop_limit) | IMDS hop limit. | `number` | `2` | no |
| <a name="input_imds_require_v2"></a> [imds_require_v2](#input_imds_require_v2) | Require IMDSv2 (recommended). | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance_type](#input_instance_type) | Instance type. | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key_name](#input_key_name) | Optional key pair name. | `string` | `null` | no |
| <a name="input_placement_group"></a> [placement_group](#input_placement_group) | Optional placement group name. | `string` | `null` | no |
| <a name="input_root_kms_key_id"></a> [root_kms_key_id](#input_root_kms_key_id) | Optional KMS key id/arn for root volume encryption. | `string` | `null` | no |
| <a name="input_root_volume_encrypted"></a> [root_volume_encrypted](#input_root_volume_encrypted) | Encrypt root volume. | `bool` | `true` | no |
| <a name="input_root_volume_size"></a> [root_volume_size](#input_root_volume_size) | Root volume size in GiB. | `number` | `30` | no |
| <a name="input_root_volume_type"></a> [root_volume_type](#input_root_volume_type) | Root volume type. | `string` | `"gp3"` | no |
| <a name="input_security_group_ids"></a> [security_group_ids](#input_security_group_ids) | Security group IDs. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply. | `map(string)` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input_tenancy) | Instance tenancy. | `string` | `"default"` | no |
| <a name="input_user_data"></a> [user_data](#input_user_data) | Optional plain-text user_data. Set user_data_replace_on_change=true when replacements are desired on changes. | `string` | `null` | no |
| <a name="input_user_data_replace_on_change"></a> [user_data_replace_on_change](#input_user_data_replace_on_change) | Whether changes to user_data should force replacement. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | n/a |
| <a name="output_id"></a> [id](#output_id) | n/a |
| <a name="output_private_ip"></a> [private_ip](#output_private_ip) | n/a |
| <a name="output_public_ip"></a> [public_ip](#output_public_ip) | n/a |
<!-- END_TF_DOCS -->

---

### efs

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
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 5.0, < 6.0 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 5.0, < 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input_name) | n/a | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids) | Subnets for mount targets (one per AZ recommended). | `list(string)` | n/a | yes |
| <a name="input_encrypted"></a> [encrypted](#input_encrypted) | n/a | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms_key_arn](#input_kms_key_arn) | Optional KMS key ARN for EFS encryption. | `string` | `null` | no |
| <a name="input_performance_mode"></a> [performance_mode](#input_performance_mode) | EFS performance mode. | `string` | `"generalPurpose"` | no |
| <a name="input_provisioned_throughput_in_mibps"></a> [provisioned_throughput_in_mibps](#input_provisioned_throughput_in_mibps) | Provisioned throughput in MiB/s when throughput_mode is provisioned. | `number` | `null` | no |
| <a name="input_security_group_ids"></a> [security_group_ids](#input_security_group_ids) | Security groups for mount targets. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply. | `map(string)` | `{}` | no |
| <a name="input_throughput_mode"></a> [throughput_mode](#input_throughput_mode) | EFS throughput mode. | `string` | `"bursting"` | no |
| <a name="input_transition_to_ia"></a> [transition_to_ia](#input_transition_to_ia) | Transition files to EFS IA to control costs. | `string` | `"AFTER_30_DAYS"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | n/a |
| <a name="output_id"></a> [id](#output_id) | n/a |
<!-- END_TF_DOCS -->

---

### iam_role

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
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 5.0, < 6.0 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 5.0, < 6.0 |

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
| <a name="input_assume_role_policy_json"></a> [assume_role_policy_json](#input_assume_role_policy_json) | Assume role policy (JSON string). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input_name) | Role name. | `string` | n/a | yes |
| <a name="input_create_instance_profile"></a> [create_instance_profile](#input_create_instance_profile) | Create an IAM instance profile for this role. Default is false for safer shared-module reuse. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input_description) | Role description. | `string` | `"Managed by OpenTofu"` | no |
| <a name="input_inline_policies_json"></a> [inline_policies_json](#input_inline_policies_json) | Map of inline policies (policy_name => JSON string). | `map(string)` | `{}` | no |
| <a name="input_instance_profile_name"></a> [instance_profile_name](#input_instance_profile_name) | Optional instance profile name override. If null, uses role name. | `string` | `null` | no |
| <a name="input_managed_policy_arns"></a> [managed_policy_arns](#input_managed_policy_arns) | Managed policy ARNs to attach. | `list(string)` | `[]` | no |
| <a name="input_permissions_boundary"></a> [permissions_boundary](#input_permissions_boundary) | Optional IAM permissions boundary policy ARN. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | Role ARN. |
| <a name="output_id"></a> [id](#output_id) | Role id. |
| <a name="output_instance_profile_arn"></a> [instance_profile_arn](#output_instance_profile_arn) | Instance profile ARN (null if not created). |
| <a name="output_instance_profile_name"></a> [instance_profile_name](#output_instance_profile_name) | Instance profile name (null if not created). |
| <a name="output_name"></a> [name](#output_name) | Role name. |
| <a name="output_permissions_boundary"></a> [permissions_boundary](#output_permissions_boundary) | Permissions boundary attached to the role (null if not set). |
<!-- END_TF_DOCS -->

---

### nlb

# nlb module (OpenTofu)

## What this module does
Creates a Network Load Balancer (NLB) with:
- Configurable listener and target group protocol
- One listener
- One target group
- Optional target attachments for `instance` or `ip`
- Optional health check overrides

Production behaviors:
- Target group name includes a random suffix to avoid name collisions on replacement
- `random_id` uses keepers so name changes when replacement-relevant inputs change
- Target group uses `create_before_destroy`
- Cross-input validations reduce invalid combinations

## Resources created
- `random_id.tg_suffix`
- `aws_lb.this`
- `aws_lb_target_group.this`
- `aws_lb_listener.this`
- Optional:
  - `aws_lb_target_group_attachment.instance` (0..N)
  - `aws_lb_target_group_attachment.ip` (0..N)

## Versioning (module-scoped tags)
Tag format example: `nlb/v0.3.0`

Consumer pinning example:
```hcl
module "nlb" {
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//nlb?ref=nlb/v0.4.0"
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
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 5.0, < 6.0 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 5.0, < 6.0 |
| <a name="provider_random"></a> [random](#provider_random) | >= 3.0, < 4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_lb_target_group_attachment.ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [random_id.tg_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input_name) | n/a | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids) | Subnets where NLB will be placed. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | n/a | `string` | n/a | yes |
| <a name="input_access_logs"></a> [access_logs](#input_access_logs) | Access logs configuration for the NLB. | <pre>object({<br>    enabled = optional(bool, true)<br>    bucket  = optional(string, "")<br>    prefix  = optional(string)<br>  })</pre> | <pre>{<br>  "bucket": "",<br>  "enabled": true<br>}</pre> | no |
| <a name="input_certificate_arn"></a> [certificate_arn](#input_certificate_arn) | ACM certificate ARN for TLS listeners. | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion_protection](#input_deletion_protection) | Enable deletion protection on the NLB. | `bool` | `true` | no |
| <a name="input_enable_cross_zone_load_balancing"></a> [enable_cross_zone_load_balancing](#input_enable_cross_zone_load_balancing) | Enable cross-zone load balancing on the NLB. | `bool` | `true` | no |
| <a name="input_health_check"></a> [health_check](#input_health_check) | Target group health check configuration. | <pre>object({<br>    enabled             = optional(bool, true)<br>    protocol            = optional(string, "TCP")<br>    port                = optional(string, "traffic-port")<br>    path                = optional(string)<br>    matcher             = optional(string)<br>    healthy_threshold   = optional(number, 3)<br>    unhealthy_threshold = optional(number, 3)<br>    interval            = optional(number, 30)<br>    timeout             = optional(number)<br>  })</pre> | `{}` | no |
| <a name="input_internal"></a> [internal](#input_internal) | Internal NLB? | `bool` | `true` | no |
| <a name="input_listener_port"></a> [listener_port](#input_listener_port) | n/a | `number` | `443` | no |
| <a name="input_listener_protocol"></a> [listener_protocol](#input_listener_protocol) | Listener protocol: TCP, TLS, UDP, or TCP_UDP. | `string` | `"TCP"` | no |
| <a name="input_tags"></a> [tags](#input_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_target_group_protocol"></a> [target_group_protocol](#input_target_group_protocol) | Target group protocol: TCP, TLS, UDP, TCP_UDP, HTTP, or HTTPS. | `string` | `"TCP"` | no |
| <a name="input_target_instance_ids"></a> [target_instance_ids](#input_target_instance_ids) | Only used when target_type == instance. | `list(string)` | `[]` | no |
| <a name="input_target_ip_addresses"></a> [target_ip_addresses](#input_target_ip_addresses) | Only used when target_type == ip. | `list(string)` | `[]` | no |
| <a name="input_target_port"></a> [target_port](#input_target_port) | n/a | `number` | `443` | no |
| <a name="input_target_type"></a> [target_type](#input_target_type) | instance | ip | `string` | `"instance"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | n/a |
| <a name="output_dns_name"></a> [dns_name](#output_dns_name) | n/a |
| <a name="output_target_group_arn"></a> [target_group_arn](#output_target_group_arn) | n/a |
| <a name="output_zone_id"></a> [zone_id](#output_zone_id) | n/a |
<!-- END_TF_DOCS -->

---

### s3

# s3 module (OpenTofu)

## What this module does
Creates an S3 bucket with production defaults:
- Encryption (SSE-S3 or SSE-KMS)
- Public access block
- Ownership controls (default: BucketOwnerEnforced)
- Optional bucket policy
- Optional server access logging
- Optional lifecycle rules with transitions, multipart cleanup, and stronger validation

## Resources created
- `aws_s3_bucket.this`
- `aws_s3_bucket_ownership_controls.this`
- `aws_s3_bucket_versioning.this`
- `aws_s3_bucket_server_side_encryption_configuration.this`
- `aws_s3_bucket_public_access_block.this`
- Optional:
  - `aws_s3_bucket_policy.this`
  - `aws_s3_bucket_logging.this`
  - `aws_s3_bucket_lifecycle_configuration.this`

## Server access logging note
If logging is enabled, the target bucket must allow log delivery.

## Versioning (module-scoped tags)
Tag format example: `s3/v0.3.0`

Consumer pinning example:
```hcl
module "s3" {
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//s3?ref=s3/v0.4.0"
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
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 5.0, < 6.0 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 5.0, < 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket_name](#input_bucket_name) | Bucket name. | `string` | n/a | yes |
| <a name="input_bucket_policy_json"></a> [bucket_policy_json](#input_bucket_policy_json) | Optional bucket policy JSON string. | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force_destroy](#input_force_destroy) | Allow bucket deletion with objects (use carefully). | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms_key_arn](#input_kms_key_arn) | Optional KMS key ARN for SSE-KMS. | `string` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle_rules](#input_lifecycle_rules) | Optional lifecycle rules. | <pre>list(object({<br>    id                                     = string<br>    status                                 = string<br>    prefix                                 = optional(string)<br>    object_size_greater_than               = optional(number)<br>    object_size_less_than                  = optional(number)<br>    expiration_days                        = optional(number)<br>    abort_incomplete_multipart_upload_days = optional(number)<br>    transitions = optional(list(object({<br>      days          = number<br>      storage_class = string<br>    })), [])<br>    noncurrent_transitions = optional(list(object({<br>      noncurrent_days = number<br>      storage_class   = string<br>    })), [])<br>    noncurrent_expiration_days = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_logging"></a> [logging](#input_logging) | Optional server access logging configuration.<br><br>IMPORTANT: The target bucket must allow log delivery. Ensure the target bucket is preconfigured<br>with the correct permissions for the S3 logging service to write logs. | <pre>object({<br>    target_bucket = string<br>    target_prefix = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_object_ownership"></a> [object_ownership](#input_object_ownership) | Bucket object ownership setting. | `string` | `"BucketOwnerEnforced"` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning_enabled](#input_versioning_enabled) | Enable versioning. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | Bucket ARN. |
| <a name="output_bucket_domain_name"></a> [bucket_domain_name](#output_bucket_domain_name) | Bucket domain name. |
| <a name="output_bucket_regional_domain_name"></a> [bucket_regional_domain_name](#output_bucket_regional_domain_name) | Bucket regional domain name. |
| <a name="output_id"></a> [id](#output_id) | Bucket id (name). |
<!-- END_TF_DOCS -->

---

### security_group

# security_group module (OpenTofu)

## What this module does
Creates an AWS Security Group and a set of ingress/egress rules.

Designed for shared use across teams:
- Uses `name_prefix` + `create_before_destroy` to avoid name-collision failures during replacement.
- Rules are maps keyed by stable names, so diffs are reviewable and rule reordering doesn't cause churn.
- Includes rule-level validations to reduce invalid combinations.

## Resources created
- `aws_security_group.this`
- `aws_security_group_rule.ingress` (0..N)
- `aws_security_group_rule.egress` (0..N)

## Versioning (module-scoped tags)
Tag format example: `security_group/v0.3.0`

Consumer pinning example:
```hcl
module "security_group" {
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//security_group?ref=security_group/v0.4.0"
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
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 5.0, < 6.0 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 5.0, < 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input_name) | Security group base name (module uses name_prefix to avoid collisions). | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC ID. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input_description) | Security group description. | `string` | `"Managed by OpenTofu"` | no |
| <a name="input_egress_rules"></a> [egress_rules](#input_egress_rules) | Egress rules keyed by a stable name. | <pre>map(object({<br>    from_port                = number<br>    to_port                  = number<br>    protocol                 = string<br>    cidr_blocks              = optional(list(string))<br>    ipv6_cidr_blocks         = optional(list(string))<br>    prefix_list_ids          = optional(list(string))<br>    source_security_group_id = optional(string)<br>    self                     = optional(bool)<br>    description              = optional(string)<br>  }))</pre> | <pre>{<br>  "allow_all": {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Default allow all egress",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "to_port": 0<br>  }<br>}</pre> | no |
| <a name="input_ingress_rules"></a> [ingress_rules](#input_ingress_rules) | Ingress rules keyed by a stable name. | <pre>map(object({<br>    from_port                = number<br>    to_port                  = number<br>    protocol                 = string<br>    cidr_blocks              = optional(list(string))<br>    ipv6_cidr_blocks         = optional(list(string))<br>    prefix_list_ids          = optional(list(string))<br>    source_security_group_id = optional(string)<br>    self                     = optional(bool)<br>    description              = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | Security group arn. |
| <a name="output_id"></a> [id](#output_id) | Security group id. |
| <a name="output_name"></a> [name](#output_name) | Security group name (AWS generated due to name_prefix). |
<!-- END_TF_DOCS -->

---

<!-- END_COMBINED_MODULE_DOCS -->

---

## Contributing

When contributing:

* maintain backward compatibility
* add validation for new inputs
* update examples
* ensure CI passes

---

## Summary

These modules provide a production-ready foundation for AWS infrastructure provisioning, balancing flexibility with guardrails. They are designed to accelerate delivery while maintaining consistency, reliability, and security.
