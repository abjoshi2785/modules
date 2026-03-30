variable "name" {
  type = string
  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "subnet_ids" {
  description = "Subnets for mount targets (one per AZ recommended)."
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet."
  }
}

variable "security_group_ids" {
  description = "Security groups for mount targets."
  type        = list(string)
  default     = []
}

variable "encrypted" {
  type    = bool
  default = true
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for EFS encryption."
  type        = string
  default     = null
  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:(key|alias)/.+", var.kms_key_arn))
    error_message = "kms_key_arn must be null or a valid KMS key or alias ARN."
  }
}

variable "transition_to_ia" {
  description = "Transition files to EFS IA to control costs."
  type        = string
  default     = "AFTER_30_DAYS"
  validation {
    condition = contains(
      ["AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS"],
      var.transition_to_ia
    )
    error_message = "transition_to_ia must be one of AFTER_7_DAYS/14/30/60/90."
  }
}

variable "performance_mode" {
  description = "EFS performance mode."
  type        = string
  default     = "generalPurpose"
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "performance_mode must be generalPurpose or maxIO."
  }
}

variable "throughput_mode" {
  description = "EFS throughput mode."
  type        = string
  default     = "bursting"
  validation {
    condition     = contains(["bursting", "elastic", "provisioned"], var.throughput_mode)
    error_message = "throughput_mode must be bursting, elastic, or provisioned."
  }
}

variable "provisioned_throughput_in_mibps" {
  description = "Provisioned throughput in MiB/s when throughput_mode is provisioned."
  type        = number
  default     = null
  validation {
    condition     = var.provisioned_throughput_in_mibps == null || var.provisioned_throughput_in_mibps > 0
    error_message = "provisioned_throughput_in_mibps must be null or > 0."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
  validation {
    condition = alltrue([
      for k in ["env", "owner", "cost-center"] : contains(keys(var.tags), k)
    ])
    error_message = "tags must include env, owner, and cost-center."
  }
}
