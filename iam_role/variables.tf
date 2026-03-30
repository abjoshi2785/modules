variable "name" {
  description = "Role name."
  type        = string
  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "description" {
  description = "Role description."
  type        = string
  default     = "Managed by OpenTofu"
}

variable "assume_role_policy_json" {
  description = "Assume role policy (JSON string)."
  type        = string
  validation {
    condition     = length(trimspace(var.assume_role_policy_json)) > 0 && can(jsondecode(var.assume_role_policy_json))
    error_message = "assume_role_policy_json must be a non-empty valid JSON string."
  }
}

variable "inline_policies_json" {
  description = "Map of inline policies (policy_name => JSON string)."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.inline_policies_json :
      length(trimspace(k)) > 0 && length(trimspace(v)) > 0 && can(jsondecode(v))
    ])
    error_message = "inline_policies_json keys must be non-empty and all values must be valid JSON strings."
  }
}

variable "permissions_boundary" {
  description = "Optional IAM permissions boundary policy ARN."
  type        = string
  default     = null

  validation {
    condition     = var.permissions_boundary == null || can(regex("^arn:[^:]+:iam::(aws|[0-9]{12}):policy/.+", var.permissions_boundary))
    error_message = "permissions_boundary must be null or a valid IAM policy ARN."
  }
}

variable "managed_policy_arns" {
  description = "Managed policy ARNs to attach."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for arn in var.managed_policy_arns :
      length(trimspace(arn)) > 0 && can(regex("^arn:[^:]+:iam::(aws|[0-9]{12}):policy/.+", arn))
    ])
    error_message = "managed_policy_arns must contain valid non-empty IAM policy ARNs."
  }
}

variable "create_instance_profile" {
  description = "Create an IAM instance profile for this role. Default is false for safer shared-module reuse."
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Optional instance profile name override. If null, uses role name."
  type        = string
  default     = null

  validation {
    condition     = var.instance_profile_name == null || length(trimspace(var.instance_profile_name)) > 0
    error_message = "instance_profile_name must be null or a non-empty string."
  }
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
