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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, < 6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0, < 4.0 |

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
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets where NLB will be placed. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |
| <a name="input_access_logs"></a> [access\_logs](#input\_access\_logs) | Access logs configuration for the NLB. | <pre>object({<br>    enabled = optional(bool, true)<br>    bucket  = optional(string, "")<br>    prefix  = optional(string)<br>  })</pre> | <pre>{<br>  "bucket": "",<br>  "enabled": false<br>}</pre> | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ACM certificate ARN for TLS listeners. | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable deletion protection on the NLB. | `bool` | `true` | no |
| <a name="input_enable_cross_zone_load_balancing"></a> [enable\_cross\_zone\_load\_balancing](#input\_enable\_cross\_zone\_load\_balancing) | Enable cross-zone load balancing on the NLB. | `bool` | `true` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | Target group health check configuration. | <pre>object({<br>    enabled             = optional(bool, true)<br>    protocol            = optional(string, "TCP")<br>    port                = optional(string, "traffic-port")<br>    path                = optional(string)<br>    matcher             = optional(string)<br>    healthy_threshold   = optional(number, 3)<br>    unhealthy_threshold = optional(number, 3)<br>    interval            = optional(number, 30)<br>    timeout             = optional(number)<br>  })</pre> | `{}` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Internal NLB? | `bool` | `true` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | n/a | `number` | `443` | no |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | Listener protocol: TCP, TLS, UDP, or TCP\_UDP. | `string` | `"TCP"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_target_group_protocol"></a> [target\_group\_protocol](#input\_target\_group\_protocol) | Target group protocol: TCP, TLS, UDP, TCP\_UDP, HTTP, or HTTPS. | `string` | `"TCP"` | no |
| <a name="input_target_instance_ids"></a> [target\_instance\_ids](#input\_target\_instance\_ids) | Only used when target\_type == instance. | `list(string)` | `[]` | no |
| <a name="input_target_ip_addresses"></a> [target\_ip\_addresses](#input\_target\_ip\_addresses) | Only used when target\_type == ip. | `list(string)` | `[]` | no |
| <a name="input_target_port"></a> [target\_port](#input\_target\_port) | n/a | `number` | `443` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | instance \| ip | `string` | `"instance"` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | NLB resource timeouts. | <pre>object({<br>    create = optional(string, "20m")<br>    update = optional(string, "20m")<br>    delete = optional(string, "20m")<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | NLB ARN. |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | NLB DNS name. |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | Target group ARN. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | NLB hosted zone ID. |
<!-- END_TF_DOCS -->
