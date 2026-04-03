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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, < 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Security group base name (module uses name\_prefix to avoid collisions). | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Security group description. | `string` | `"Managed by OpenTofu"` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | Egress rules keyed by a stable name. | <pre>map(object({<br>    from_port                = number<br>    to_port                  = number<br>    protocol                 = string<br>    cidr_blocks              = optional(list(string))<br>    ipv6_cidr_blocks         = optional(list(string))<br>    prefix_list_ids          = optional(list(string))<br>    source_security_group_id = optional(string)<br>    self                     = optional(bool)<br>    description              = optional(string)<br>  }))</pre> | <pre>{<br>  "allow_all": {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Default allow all egress",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "to_port": 0<br>  }<br>}</pre> | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | Ingress rules keyed by a stable name. | <pre>map(object({<br>    from_port                = number<br>    to_port                  = number<br>    protocol                 = string<br>    cidr_blocks              = optional(list(string))<br>    ipv6_cidr_blocks         = optional(list(string))<br>    prefix_list_ids          = optional(list(string))<br>    source_security_group_id = optional(string)<br>    self                     = optional(bool)<br>    description              = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Security group arn. |
| <a name="output_id"></a> [id](#output\_id) | Security group id. |
| <a name="output_name"></a> [name](#output\_name) | Security group name (AWS generated due to name\_prefix). |
<!-- END_TF_DOCS -->
