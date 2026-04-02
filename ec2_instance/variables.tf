variable "name" {
  type = string
  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "ami_id" {
  description = "AMI ID."
  type        = string
  validation {
    condition     = length(trimspace(var.ami_id)) > 0
    error_message = "ami_id must not be empty."
  }
}

variable "instance_type" {
  description = "Instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID."
  type        = string
  validation {
    condition     = length(trimspace(var.subnet_id)) > 0
    error_message = "subnet_id must not be empty."
  }
}

variable "security_group_ids" {
  description = "Security group IDs."
  type        = list(string)
  default     = []
}

variable "associate_public_ip" {
  description = "Associate public IP."
  type        = bool
  default     = false
}

variable "placement_group" {
  description = "Optional placement group name."
  type        = string
  default     = null
}

variable "tenancy" {
  description = "Instance tenancy."
  type        = string
  default     = "default"
  validation {
    condition     = contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "tenancy must be default, dedicated, or host."
  }
}

variable "capacity_reservation_preference" {
  description = "Capacity reservation preference."
  type        = string
  default     = "open"
  validation {
    condition     = contains(["open", "none"], var.capacity_reservation_preference)
    error_message = "capacity_reservation_preference must be open or none."
  }
}

variable "capacity_reservation_target_id" {
  description = "Optional capacity reservation ID when targeting a specific reservation."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Optional key pair name."
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "Optional instance profile name."
  type        = string
  default     = null
}

variable "user_data" {
  description = "Optional plain-text user_data. Set user_data_replace_on_change=true when replacements are desired on changes."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Whether changes to user_data should force replacement."
  type        = bool
  default     = false
}

variable "detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring."
  type        = bool
  default     = true
}

variable "ebs_optimized" {
  description = "Enable EBS optimization when supported by the instance type."
  type        = bool
  default     = true
}

variable "disable_api_termination" {
  description = "Enable termination protection for the instance."
  type        = bool
  default     = false
}

variable "additional_ebs_volumes" {
  description = "Additional EBS volumes to attach at launch."
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string, "gp3")
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool, true)
    iops                  = optional(number)
    throughput            = optional(number)
  }))
  default = []
}

variable "imds_require_v2" {
  description = "Require IMDSv2 (recommended)."
  type        = bool
  default     = true
}

variable "imds_hop_limit" {
  description = "IMDS hop limit."
  type        = number
  default     = 2
  validation {
    condition     = var.imds_hop_limit >= 1 && var.imds_hop_limit <= 64
    error_message = "imds_hop_limit must be between 1 and 64."
  }
}

variable "root_volume_size" {
  description = "Root volume size in GiB."
  type        = number
  default     = 30
  validation {
    condition     = var.root_volume_size >= 8
    error_message = "root_volume_size must be >= 8 GiB."
  }
}

variable "root_volume_type" {
  description = "Root volume type."
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "sc1", "st1", "standard"], var.root_volume_type)
    error_message = "root_volume_type must be a valid EBS volume type."
  }
}

variable "root_volume_encrypted" {
  description = "Encrypt root volume."
  type        = bool
  default     = true
}

variable "root_kms_key_id" {
  description = "Optional KMS key id/arn for root volume encryption."
  type        = string
  default     = null
  validation {
    condition     = var.root_kms_key_id == null || can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:(key|alias)/.+", var.root_kms_key_id))
    error_message = "root_kms_key_id must be null or a valid KMS key or alias ARN."
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
