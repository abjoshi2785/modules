locals {
  name = var.name
  tags = merge(var.tags, { Name = local.name })
}

# checkov:skip=CKV2_AWS_5: This reusable module creates a standalone security group. Attachments are performed by consuming modules/stacks.
resource "aws_security_group" "this" {
  name_prefix = "${local.name}-"
  description = var.description
  vpc_id      = var.vpc_id
  tags        = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = var.ingress_rules

  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port = each.value.from_port
  to_port   = each.value.to_port
  protocol  = each.value.protocol

  cidr_blocks              = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
  self                     = try(each.value.self, null)

  description = try(each.value.description, null)
}

resource "aws_security_group_rule" "egress" {
  for_each = var.egress_rules

  type              = "egress"
  security_group_id = aws_security_group.this.id

  from_port = each.value.from_port
  to_port   = each.value.to_port
  protocol  = each.value.protocol

  cidr_blocks              = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
  self                     = try(each.value.self, null)

  description = try(each.value.description, null)
}
