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
  source = "git::ssh://git@github.com/my-org/terraform-modules.git//terraform/modules/nlb?ref=nlb/v0.4.0"
}
```

## Development
- `tofu fmt -recursive`
- `tofu validate`

## Inputs / Outputs
See `variables.tf` and `outputs.tf`.
