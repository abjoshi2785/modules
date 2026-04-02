variable "name" {
  type = string
  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "ami_id" {
  type = string
  validation {
    condition     = length(trimspace(var.ami_id)) > 0
    error_message = "ami_id must not be empty."
  }
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_ids" {
  type = list(string)
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet."
  }
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "key_name" {
  type    = string
  default = null
}

variable "placement_group" {
  description = "Optional placement group name for the launch template."
  type        = string
  default     = null
}

variable "capacity_reservation_preference" {
  description = "Capacity reservation preference for launched instances."
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

variable "iam_instance_profile" {
  description = "Optional instance profile name. Set null to skip."
  type        = string
  default     = null
}

variable "user_data" {
  description = "Optional plain-text user_data. The module base64-encodes it for the launch template. Changing it updates the launch template and may trigger instance refresh depending on instance_refresh_triggers."
  type        = string
  default     = null
}

variable "launch_template_version" {
  description = "Launch template version for the ASG. Use $Latest, $Default, or a specific version number."
  type        = string
  default     = "$Latest"
  validation {
    condition     = can(regex("^(\\$Latest|\\$Default|[0-9]+)$", var.launch_template_version))
    error_message = "launch_template_version must be $Latest, $Default, or a numeric version."
  }
}

variable "launch_template_update_default_version" {
  description = "Update the launch template default version when changes are made."
  type        = bool
  default     = true
}

variable "detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring in the launch template."
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "Enable EBS optimization when supported by the instance type."
  type        = bool
  default     = false
}

variable "additional_ebs_volumes" {
  description = "Additional EBS volumes to attach through the launch template."
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
  default     = 1
  validation {
    condition     = var.imds_hop_limit >= 1 && var.imds_hop_limit <= 64
    error_message = "imds_hop_limit must be between 1 and 64."
  }
}

variable "root_device_name" {
  description = "Root device name for block mapping."
  type        = string
  default     = "/dev/xvda"
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

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "health_check_type" {
  type    = string
  default = "EC2"
  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "health_check_type must be EC2 or ELB."
  }
}

variable "wait_for_capacity_timeout" {
  description = "Maximum time Terraform waits for ASG capacity stabilization."
  type        = string
  default     = "15m"
}

variable "health_check_grace_period" {
  description = "Seconds to ignore failing health checks after instance launch."
  type        = number
  default     = 300
}

variable "target_group_arns" {
  type    = list(string)
  default = []
}

variable "enable_instance_refresh" {
  description = "Enable ASG instance refresh on launch template changes by default."
  type        = bool
  default     = true
}

variable "instance_refresh_min_healthy_percentage" {
  description = "Minimum healthy percentage during refresh."
  type        = number
  default     = 50
  validation {
    condition     = var.instance_refresh_min_healthy_percentage >= 0 && var.instance_refresh_min_healthy_percentage <= 100
    error_message = "instance_refresh_min_healthy_percentage must be between 0 and 100."
  }
}

variable "instance_refresh_instance_warmup" {
  description = "Warmup time (seconds) before considering an instance healthy."
  type        = number
  default     = 300
  validation {
    condition     = var.instance_refresh_instance_warmup >= 0
    error_message = "instance_refresh_instance_warmup must be >= 0."
  }
}

variable "instance_refresh_triggers" {
  description = "Triggers that cause an instance refresh."
  type        = list(string)
  default     = ["launch_template"]
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
