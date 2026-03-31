locals {
  tags = merge(var.tags, { Name = var.name })
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id
resource "random_id" "tg_suffix" {
  byte_length = 3

  keepers = {
    port            = var.target_port
    protocol        = var.target_group_protocol
    vpc_id          = var.vpc_id
    target_type     = var.target_type
    health_protocol = var.health_check.protocol
    health_path     = try(var.health_check.path, "")
    health_port     = var.health_check.port
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "this" {
  name                             = var.name
  load_balancer_type               = "network"
  internal                         = var.internal
  subnets                          = var.subnet_ids
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.deletion_protection

  access_logs {
    enabled = var.access_logs.enabled
    bucket  = var.access_logs.bucket
    prefix  = try(var.access_logs.prefix, null)
  }

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }

  tags = local.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "this" {
  name = substr("${var.name}-tg-${random_id.tg_suffix.hex}", 0, 32)

  port        = var.target_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  lifecycle {
    create_before_destroy = true

    precondition {
      condition = (
        contains(["TCP", "TLS"], var.listener_protocol) && contains(["TCP", "TLS", "HTTP", "HTTPS"], var.target_group_protocol)
        ) || (
        var.listener_protocol == "UDP" && contains(["UDP", "TCP_UDP"], var.target_group_protocol)
        ) || (
        var.listener_protocol == "TCP_UDP" && var.target_group_protocol == "TCP_UDP"
      )
      error_message = "Invalid listener_protocol and target_group_protocol combination for NLB."
    }

    precondition {
      condition = (
        contains(["HTTP", "HTTPS"], var.health_check.protocol)
        ? contains(["TCP", "TLS", "HTTP", "HTTPS"], var.target_group_protocol)
        : true
      )
      error_message = "HTTP/HTTPS health checks require a compatible target_group_protocol."
    }

    precondition {
      condition = (
        contains(["UDP", "TCP_UDP"], var.listener_protocol)
        ? !contains(["HTTP", "HTTPS"], var.health_check.protocol)
        : true
      )
      error_message = "UDP or TCP_UDP listeners should not use HTTP/HTTPS health checks in this module."
    }

    precondition {
      condition = (
        (var.target_type == "instance" && length(var.target_instance_ids) > 0 && length(var.target_ip_addresses) == 0) ||
        (var.target_type == "ip" && length(var.target_ip_addresses) > 0 && length(var.target_instance_ids) == 0)
      )
      error_message = "Provide exactly one non-empty target list matching target_type."
    }
  }

  health_check {
    enabled             = var.health_check.enabled
    protocol            = var.health_check.protocol
    port                = var.health_check.port
    path                = contains(["HTTP", "HTTPS"], var.health_check.protocol) ? try(var.health_check.path, null) : null
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    interval            = var.health_check.interval
    timeout             = try(var.health_check.timeout, null)
    matcher             = contains(["HTTP", "HTTPS"], var.health_check.protocol) ? try(var.health_check.matcher, null) : null
  }

  tags = local.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  certificate_arn   = var.listener_protocol == "TLS" ? var.certificate_arn : null

  lifecycle {
    precondition {
      condition     = var.listener_protocol != "TLS" || var.certificate_arn != null
      error_message = "certificate_arn must be set when listener_protocol is TLS."
    }
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "instance" {
  for_each         = var.target_type == "instance" ? toset(var.target_instance_ids) : toset([])
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = var.target_port
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "ip" {
  for_each         = var.target_type == "ip" ? toset(var.target_ip_addresses) : toset([])
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = var.target_port
}