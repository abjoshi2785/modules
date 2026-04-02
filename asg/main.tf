locals {
  tags = merge(var.tags, { Name = var.name })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids
  placement {
    group_name = var.placement_group
  }
  user_data              = var.user_data == null ? null : base64encode(var.user_data)
  update_default_version = var.launch_template_update_default_version
  ebs_optimized          = var.ebs_optimized
  monitoring {
    enabled = var.detailed_monitoring
  }

  capacity_reservation_specification {
    capacity_reservation_preference = var.capacity_reservation_preference

    dynamic "capacity_reservation_target" {
      for_each = var.capacity_reservation_target_id == null ? [] : [1]
      content {
        capacity_reservation_id = var.capacity_reservation_target_id
      }
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.imds_require_v2 ? "required" : "optional"
    http_put_response_hop_limit = var.imds_hop_limit
  }

  block_device_mappings {
    device_name = var.root_device_name
    ebs {
      volume_size = var.root_volume_size
      volume_type = var.root_volume_type
      encrypted   = var.root_volume_encrypted
      kms_key_id  = var.root_kms_key_id
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.additional_ebs_volumes
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        delete_on_termination = try(block_device_mappings.value.delete_on_termination, true)
        encrypted             = try(block_device_mappings.value.encrypted, true)
        kms_key_id            = try(block_device_mappings.value.kms_key_id, null)
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = try(block_device_mappings.value.volume_type, "gp3")
        iops                  = try(block_device_mappings.value.iops, null)
        throughput            = try(block_device_mappings.value.throughput, null)
      }
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile == null ? [] : [1]
    content {
      name = var.iam_instance_profile
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  lifecycle {
    precondition {
      condition     = !(var.root_kms_key_id != null && !var.root_volume_encrypted)
      error_message = "root_kms_key_id can only be set when root_volume_encrypted is true."
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "this" {
  name                      = var.name
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  target_group_arns         = var.target_group_arns
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  launch_template {
    id      = aws_launch_template.this.id
    version = var.launch_template_version
  }

  dynamic "instance_refresh" {
    for_each = var.enable_instance_refresh ? [1] : []
    content {
      strategy = "Rolling"
      preferences {
        min_healthy_percentage = var.instance_refresh_min_healthy_percentage
        instance_warmup        = var.instance_refresh_instance_warmup
      }
      triggers = var.instance_refresh_triggers
    }
  }

  lifecycle {
    precondition {
      condition     = length(var.subnet_ids) > 0
      error_message = "subnet_ids must contain at least one subnet."
    }

    precondition {
      condition     = var.min_size >= 0 && var.max_size >= var.min_size
      error_message = "max_size must be greater than or equal to min_size, and min_size must be >= 0."
    }

    precondition {
      condition     = var.desired_capacity >= var.min_size && var.desired_capacity <= var.max_size
      error_message = "desired_capacity must be between min_size and max_size."
    }
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
