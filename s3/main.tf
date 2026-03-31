locals {
  tags = merge(var.tags, { Name = var.bucket_name })
}

# checkov:skip=CKV_AWS_144: Cross-region replication is workload-dependent and not enabled by default in this reusable module.
# checkov:skip=CKV2_AWS_62: Event notifications are workload-dependent and not enabled by default in this reusable module.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = local.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }

  lifecycle {
    precondition {
      condition     = var.kms_key_arn == null || can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:(key|alias)/.+", var.kms_key_arn))
      error_message = "kms_key_arn must be null or a valid KMS key or alias ARN."
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy_json == null ? 0 : 1
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy_json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging
resource "aws_s3_bucket_logging" "this" {
  count         = var.logging == null ? 0 : 1
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.logging.target_bucket
  target_prefix = try(var.logging.target_prefix, null)

  lifecycle {
    precondition {
      condition     = var.logging == null || length(trimspace(var.logging.target_bucket)) > 0
      error_message = "logging.target_bucket must be a non-empty bucket name when logging is configured."
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count      = length(var.lifecycle_rules) == 0 ? 0 : 1
  bucket     = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket_versioning.this]

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {
        for_each = (
          try(rule.value.prefix, null) == null &&
          try(rule.value.object_size_greater_than, null) == null &&
          try(rule.value.object_size_less_than, null) == null
        ) ? [] : [1]

        content {
          prefix                   = try(rule.value.prefix, null)
          object_size_greater_than = try(rule.value.object_size_greater_than, null)
          object_size_less_than    = try(rule.value.object_size_less_than, null)
        }
      }

      dynamic "expiration" {
        for_each = try(rule.value.expiration_days, null) == null ? [] : [rule.value.expiration_days]

        content {
          days = expiration.value
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(rule.value.abort_incomplete_multipart_upload_days, null) == null ? [] : [rule.value.abort_incomplete_multipart_upload_days]

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }

      dynamic "transition" {
        for_each = try(rule.value.transitions, [])

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = try(rule.value.noncurrent_transitions, [])

        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = try(rule.value.noncurrent_expiration_days, null) == null ? [] : [rule.value.noncurrent_expiration_days]

        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }
    }
  }
}