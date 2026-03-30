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
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//terraform/modules/security_group?ref=security_group/v0.4.0"
}
```

## Development
- `tofu fmt -recursive`
- `tofu validate`

## Inputs / Outputs
See `variables.tf` and `outputs.tf`.
