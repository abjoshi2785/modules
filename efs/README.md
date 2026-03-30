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
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//terraform/modules/efs?ref=efs/v0.4.0"
}
```

## Development
- `tofu fmt -recursive`
- `tofu validate`

## Inputs / Outputs
See `variables.tf` and `outputs.tf`.
