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
<!-- END_TF_DOCS -->
