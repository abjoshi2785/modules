locals {
  tags = merge(var.tags, { Name = var.name })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip
  availability_zone           = var.availability_zone
  placement_group             = var.placement_group
  tenancy                     = var.tenancy
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data
  monitoring                  = var.detailed_monitoring
  ebs_optimized               = var.ebs_optimized
  disable_api_termination     = var.disable_api_termination
  user_data_replace_on_change = var.user_data_replace_on_change

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

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = var.root_volume_encrypted
    kms_key_id  = var.root_kms_key_id
  }

  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      delete_on_termination = try(ebs_block_device.value.delete_on_termination, true)
      encrypted             = try(ebs_block_device.value.encrypted, true)
      kms_key_id            = try(ebs_block_device.value.kms_key_id, null)
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = try(ebs_block_device.value.volume_type, "gp3")
      iops                  = try(ebs_block_device.value.iops, null)
      throughput            = try(ebs_block_device.value.throughput, null)
    }
  }

  lifecycle {
    precondition {
      condition     = !(var.root_kms_key_id != null && !var.root_volume_encrypted)
      error_message = "root_kms_key_id can only be set when root_volume_encrypted is true."
    }
  }

  tags = local.tags
}
