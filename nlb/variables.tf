variable "name" {
  type = string
  validation {
    condition     = length(trimspace(var.name)) > 0 && length(var.name) <= 22
    error_message = "name must be non-empty and no longer than 22 characters (target group appends -tg- plus 6 hex chars to stay within AWS 32-char limit)."
  }
}

variable "internal" {
  description = "Internal NLB?"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection on the NLB."
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing on the NLB."
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "Subnets where NLB will be placed."
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet."
  }
}

variable "vpc_id" {
  type = string
  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "listener_port" {
  type    = number
  default = 443
  validation {
    condition     = var.listener_port >= 1 && var.listener_port <= 65535
    error_message = "listener_port must be 1..65535."
  }
}

variable "target_port" {
  type    = number
  default = 443
  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "target_port must be 1..65535."
  }
}

variable "certificate_arn" {
  description = "ACM certificate ARN for TLS listeners."
  type        = string
  default     = null

  validation {
    condition     = var.certificate_arn == null || can(regex("^arn:[^:]+:acm:[^:]+:[0-9]{12}:certificate/.+", var.certificate_arn))
    error_message = "certificate_arn must be null or a valid ACM certificate ARN."
  }
}

variable "listener_protocol" {
  description = "Listener protocol: TCP, TLS, UDP, or TCP_UDP."
  type        = string
  default     = "TCP"
  validation {
    condition     = contains(["TCP", "TLS", "UDP", "TCP_UDP"], var.listener_protocol)
    error_message = "listener_protocol must be one of TCP, TLS, UDP, TCP_UDP."
  }
}

variable "target_group_protocol" {
  description = "Target group protocol: TCP, TLS, UDP, TCP_UDP, HTTP, or HTTPS."
  type        = string
  default     = "TCP"
  validation {
    condition     = contains(["TCP", "TLS", "UDP", "TCP_UDP", "HTTP", "HTTPS"], var.target_group_protocol)
    error_message = "target_group_protocol must be one of TCP, TLS, UDP, TCP_UDP, HTTP, HTTPS."
  }
}

variable "target_type" {
  description = "instance | ip"
  type        = string
  default     = "instance"
  validation {
    condition     = contains(["instance", "ip"], var.target_type)
    error_message = "target_type must be one of: instance, ip."
  }
}

variable "target_instance_ids" {
  description = "Only used when target_type == instance."
  type        = list(string)
  default     = []
}

variable "target_ip_addresses" {
  description = "Only used when target_type == ip."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for ip in var.target_ip_addresses : can(cidrhost("${ip}/32", 0))
    ])
    error_message = "target_ip_addresses must be valid IPv4 address strings."
  }
}

variable "health_check" {
  description = "Target group health check configuration."
  type = object({
    enabled             = optional(bool, true)
    protocol            = optional(string, "TCP")
    port                = optional(string, "traffic-port")
    path                = optional(string)
    matcher             = optional(string)
    healthy_threshold   = optional(number, 3)
    unhealthy_threshold = optional(number, 3)
    interval            = optional(number, 30)
    timeout             = optional(number)
  })
  default = {}

  validation {
    condition     = contains(["TCP", "HTTP", "HTTPS"], var.health_check.protocol)
    error_message = "health_check.protocol must be TCP, HTTP, or HTTPS."
  }

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.health_check.protocol) || try(var.health_check.path, null) == null
    error_message = "health_check.path can only be set when health_check.protocol is HTTP or HTTPS."
  }
}

variable "access_logs" {
  description = "Access logs configuration for the NLB."
  type = object({
    enabled = optional(bool, true)
    bucket  = optional(string, "")
    prefix  = optional(string)
  })
  default = {
    enabled = false
    bucket  = ""
  }

  validation {
    condition = (
      var.access_logs.enabled
      ? length(trimspace(var.access_logs.bucket)) > 0
      : true
    )
    error_message = "access_logs.bucket must be a non-empty S3 bucket name when access_logs is enabled."
  }
}

variable "timeouts" {
  description = "NLB resource timeouts."
  type = object({
    create = optional(string, "20m")
    update = optional(string, "20m")
    delete = optional(string, "20m")
  })
  default = {}

  validation {
    condition     = can(regex("^[0-9]+[mhs]$", var.timeouts.create))
    error_message = "timeouts.create must be a duration string like 20m, 1h, or 300s."
  }

  validation {
    condition     = can(regex("^[0-9]+[mhs]$", var.timeouts.update))
    error_message = "timeouts.update must be a duration string like 20m, 1h, or 300s."
  }

  validation {
    condition     = can(regex("^[0-9]+[mhs]$", var.timeouts.delete))
    error_message = "timeouts.delete must be a duration string like 20m, 1h, or 300s."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
  validation {
    condition = alltrue([
      for k in ["env", "owner", "cost-center"] :
      length(trimspace(lookup(var.tags, k, ""))) > 0
    ])
    error_message = "tags must include non-empty env, owner, and cost-center."
  }
}