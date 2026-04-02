locals {
  tags = merge(var.tags, { Name = var.name })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system
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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy
resource "aws_efs_file_system_policy" "this" {
  count = var.file_system_policy_json != null ? 1 : 0

  file_system_id = aws_efs_file_system.this.id
  policy         = var.file_system_policy_json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point
resource "aws_efs_access_point" "this" {
  for_each = var.access_points

  file_system_id = aws_efs_file_system.this.id

  dynamic "posix_user" {
    for_each = each.value.posix_user != null ? [each.value.posix_user] : []
    content {
      uid            = posix_user.value.uid
      gid            = posix_user.value.gid
      secondary_gids = try(posix_user.value.secondary_gids, null)
    }
  }

  dynamic "root_directory" {
    for_each = each.value.root_directory != null ? [each.value.root_directory] : []
    content {
      path = root_directory.value.path

      dynamic "creation_info" {
        for_each = root_directory.value.creation_info != null ? [root_directory.value.creation_info] : []
        content {
          owner_uid   = creation_info.value.owner_uid
          owner_gid   = creation_info.value.owner_gid
          permissions = creation_info.value.permissions
        }
      }
    }
  }

  tags = merge(local.tags, { Name = "${var.name}-${each.key}" })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target
resource "aws_efs_mount_target" "this" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = var.security_group_ids
}