variable "bucket_name" {
  description = "Bucket name."
  type        = string
  validation {
    condition     = length(trimspace(var.bucket_name)) > 0
    error_message = "bucket_name must not be empty."
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
}

variable "bucket_policy_json" {
  description = "Optional bucket policy JSON string."
  type        = string
  default     = null
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
        try(rule.expiration_days, null) != null ||
        try(rule.noncurrent_expiration_days, null) != null ||
        try(rule.abort_incomplete_multipart_upload_days, null) != null ||
        length(try(rule.transitions, [])) > 0 ||
        length(try(rule.noncurrent_transitions, [])) > 0
      )
    ])
    error_message = "Each lifecycle rule must define at least one action."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.lifecycle_rules : [
        try(rule.expiration_days, null) == null ? true : try(rule.expiration_days > 0, false),
        try(rule.noncurrent_expiration_days, null) == null ? true : try(rule.noncurrent_expiration_days > 0, false),
        try(rule.abort_incomplete_multipart_upload_days, null) == null ? true : try(rule.abort_incomplete_multipart_upload_days > 0, false),
        try(rule.object_size_greater_than, null) == null ? true : try(rule.object_size_greater_than >= 0, false),
        try(rule.object_size_less_than, null) == null ? true : try(rule.object_size_less_than > 0, false),
        alltrue([
          for t in try(rule.transitions, []) :
          t.days > 0 && contains(
            ["STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "GLACIER_IR", "DEEP_ARCHIVE"],
            t.storage_class
          )
        ]),
        alltrue([
          for t in try(rule.noncurrent_transitions, []) :
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
        try(rule.object_size_greater_than, null) == null ||
        try(rule.object_size_less_than, null) == null ||
        try(rule.object_size_less_than > rule.object_size_greater_than, false)
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
      contains(keys(var.tags), k) && length(trimspace(var.tags[k])) > 0
    ])
    error_message = "tags must include non-empty env, owner, and cost-center."
  }
}