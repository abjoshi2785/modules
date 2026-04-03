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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, < 6.0 |

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
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Bucket name. | `string` | n/a | yes |
| <a name="input_bucket_policy_json"></a> [bucket\_policy\_json](#input\_bucket\_policy\_json) | Optional bucket policy JSON string. | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Allow bucket deletion with objects (use carefully). | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Optional KMS key ARN for SSE-KMS. | `string` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Optional lifecycle rules. | <pre>list(object({<br>    id                                     = string<br>    status                                 = string<br>    prefix                                 = optional(string)<br>    object_size_greater_than               = optional(number)<br>    object_size_less_than                  = optional(number)<br>    expiration_days                        = optional(number)<br>    abort_incomplete_multipart_upload_days = optional(number)<br>    transitions = optional(list(object({<br>      days          = number<br>      storage_class = string<br>    })), [])<br>    noncurrent_transitions = optional(list(object({<br>      noncurrent_days = number<br>      storage_class   = string<br>    })), [])<br>    noncurrent_expiration_days = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | Optional server access logging configuration.<br><br>IMPORTANT: The target bucket must allow log delivery. Ensure the target bucket is preconfigured<br>with the correct permissions for the S3 logging service to write logs. | <pre>object({<br>    target_bucket = string<br>    target_prefix = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | Bucket object ownership setting. | `string` | `"BucketOwnerEnforced"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable versioning. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Bucket ARN. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | Bucket domain name. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | Bucket regional domain name. |
| <a name="output_id"></a> [id](#output\_id) | Bucket id (name). |
<!-- END_TF_DOCS -->
