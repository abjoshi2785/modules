variable "bucket_name" {
  description = "Bucket name."
  type        = string

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "bucket_name must be between 3 and 63 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must start and end with a lowercase letter or number, and contain only lowercase letters, numbers, hyphens, and periods."
  }

  validation {
    condition     = !can(regex("\\.\\.", var.bucket_name))
    error_message = "bucket_name must not contain consecutive periods."
  }

  validation {
    condition     = !can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", var.bucket_name))
    error_message = "bucket_name must not be formatted as an IP address."
  }
}

variable "force_destroy" {
  description = "Allow bucket deletion with objects (use carefully)."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Bucket object ownership setting."
  type        = string
  default     = "BucketOwnerEnforced"
  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred, or ObjectWriter."
  }
}

variable "versioning_enabled" {
  description = "Enable versioning."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for SSE-KMS."
  type        = string
  default     = null
  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:(key|alias)/.+", var.kms_key_arn))
    error_message = "kms_key_arn must be null or a valid KMS key or alias ARN."
  }
}

variable "bucket_policy_json" {
  description = "Optional bucket policy JSON string."
  type        = string
  default     = null
  validation {
    condition     = var.bucket_policy_json == null || can(jsondecode(var.bucket_policy_json))
    error_message = "bucket_policy_json must be null or a valid JSON string."
  }
}

variable "logging" {
  description = <<EOT
Optional server access logging configuration.

IMPORTANT: The target bucket must allow log delivery. Ensure the target bucket is preconfigured
with the correct permissions for the S3 logging service to write logs.
EOT
  type = object({
    target_bucket = string
    target_prefix = optional(string)
  })
  default = null

  validation {
    condition     = var.logging == null || length(trimspace(var.logging.target_bucket)) > 0
    error_message = "logging.target_bucket must be a non-empty bucket name when logging is configured."
  }
}

variable "lifecycle_rules" {
  description = "Optional lifecycle rules."
  type = list(object({
    id                                     = string
    status                                 = string
    prefix                                 = optional(string)
    object_size_greater_than               = optional(number)
    object_size_less_than                  = optional(number)
    expiration_days                        = optional(number)
    abort_incomplete_multipart_upload_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_transitions = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })), [])
    noncurrent_expiration_days = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      length(trimspace(rule.id)) > 0 && contains(["Enabled", "Disabled"], rule.status)
    ])
    error_message = "Each lifecycle rule must have a non-empty id and status of Enabled or Disabled."
  }

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules : (
        rule.expiration_days != null ||
        rule.noncurrent_expiration_days != null ||
        rule.abort_incomplete_multipart_upload_days != null ||
        length(rule.transitions) > 0 ||
        length(rule.noncurrent_transitions) > 0
      )
    ])
    error_message = "Each lifecycle rule must define at least one action."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.lifecycle_rules : [
        rule.expiration_days == null ? true : rule.expiration_days > 0,
        rule.noncurrent_expiration_days == null ? true : rule.noncurrent_expiration_days > 0,
        rule.abort_incomplete_multipart_upload_days == null ? true : rule.abort_incomplete_multipart_upload_days > 0,
        rule.object_size_greater_than == null ? true : rule.object_size_greater_than >= 0,
        rule.object_size_less_than == null ? true : rule.object_size_less_than > 0,
        alltrue([
          for t in rule.transitions :
          t.days > 0 && contains(
            ["STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "GLACIER_IR", "DEEP_ARCHIVE"],
            t.storage_class
          )
        ]),
        alltrue([
          for t in rule.noncurrent_transitions :
          t.noncurrent_days > 0 && contains(
            ["STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "GLACIER_IR", "DEEP_ARCHIVE"],
            t.storage_class
          )
        ])
      ]
    ]))
    error_message = "Lifecycle rule numeric values must be valid and greater than zero where applicable, and storage classes must be valid S3 transition classes."
  }

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      (
        rule.object_size_greater_than == null ||
        rule.object_size_less_than == null ||
        rule.object_size_less_than > rule.object_size_greater_than
      )
    ])
    error_message = "When both object_size_greater_than and object_size_less_than are set, object_size_less_than must be greater than object_size_greater_than."
  }
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([
      for k in ["env", "owner", "cost-center"] :
      length(trimspace(lookup(var.tags, k, ""))) > 0
    ])
    error_message = "tags must include non-empty env, owner, and cost-center."
  }
}