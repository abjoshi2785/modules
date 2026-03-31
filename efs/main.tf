locals {
  tags = merge(var.tags, { Name = var.name })
}

resource "aws_efs_file_system" "this" {
  creation_token                  = var.name
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_arn
  performance_mode                = var.performance_mode
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null
  tags                            = local.tags

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  lifecycle {
    precondition {
      condition     = !(var.kms_key_arn != null && !var.encrypted)
      error_message = "kms_key_arn can only be set when encrypted is true."
    }

    precondition {
      condition = (
        var.throughput_mode == "provisioned"
        ? var.provisioned_throughput_in_mibps != null && var.provisioned_throughput_in_mibps > 0
        : var.provisioned_throughput_in_mibps == null
      )
      error_message = "When throughput_mode is provisioned, provisioned_throughput_in_mibps must be greater than 0. Otherwise it must be null."
    }
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = var.security_group_ids
}