variable "name" {
  description = "Security group base name (module uses name_prefix to avoid collisions)."
  type        = string
  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "description" {
  description = "Security group description."
  type        = string
  default     = "Managed by OpenTofu"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

variable "ingress_rules" {
  description = "Ingress rules keyed by a stable name."
  type = map(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks         = optional(list(string))
    prefix_list_ids          = optional(list(string))
    source_security_group_id = optional(string)
    self                     = optional(bool)
    description              = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in values(var.ingress_rules) : (
        rule.protocol == "-1" ? (rule.from_port == 0 && rule.to_port == 0) : (rule.from_port >= 0 && rule.to_port >= rule.from_port)
      )
    ])
    error_message = "Each ingress rule must use from_port/to_port >= 0, and protocol -1 must use from_port=0 and to_port=0."
  }

  validation {
    condition = alltrue([
      for rule in values(var.ingress_rules) : (
        length(compact([
          try(length(rule.cidr_blocks) > 0 ? "cidr" : "", ""),
          try(length(rule.ipv6_cidr_blocks) > 0 ? "ipv6" : "", ""),
          try(length(rule.prefix_list_ids) > 0 ? "prefix" : "", ""),
          try(rule.source_security_group_id != null && trimspace(rule.source_security_group_id) != "" ? "sg" : "", ""),
          try(rule.self ? "self" : "", "")
        ])) > 0
      )
    ])
    error_message = "Each ingress rule must define at least one source: cidr_blocks, ipv6_cidr_blocks, prefix_list_ids, source_security_group_id, or self."
  }
}

variable "egress_rules" {
  description = "Egress rules keyed by a stable name."
  type = map(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks         = optional(list(string))
    prefix_list_ids          = optional(list(string))
    source_security_group_id = optional(string)
    self                     = optional(bool)
    description              = optional(string)
  }))
  default = {
    allow_all = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Default allow all egress"
    }
  }

  validation {
    condition = alltrue([
      for rule in values(var.egress_rules) : (
        rule.protocol == "-1" ? (rule.from_port == 0 && rule.to_port == 0) : (rule.from_port >= 0 && rule.to_port >= rule.from_port)
      )
    ])
    error_message = "Each egress rule must use from_port/to_port >= 0, and protocol -1 must use from_port=0 and to_port=0."
  }

  validation {
    condition = alltrue([
      for rule in values(var.egress_rules) : (
        length(compact([
          try(length(rule.cidr_blocks) > 0 ? "cidr" : "", ""),
          try(length(rule.ipv6_cidr_blocks) > 0 ? "ipv6" : "", ""),
          try(length(rule.prefix_list_ids) > 0 ? "prefix" : "", ""),
          try(rule.source_security_group_id != null && trimspace(rule.source_security_group_id) != "" ? "sg" : "", ""),
          try(rule.self ? "self" : "", "")
        ])) > 0
      )
    ])
    error_message = "Each egress rule must define at least one destination: cidr_blocks, ipv6_cidr_blocks, prefix_list_ids, source_security_group_id, or self."
  }
}
