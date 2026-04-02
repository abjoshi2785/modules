output "file_system_id" {
  description = "EFS file system ID."
  value       = aws_efs_file_system.this.id
}

output "file_system_arn" {
  description = "EFS file system ARN."
  value       = aws_efs_file_system.this.arn
}

output "dns_name" {
  description = "EFS DNS name for mounting."
  value       = aws_efs_file_system.this.dns_name
}

output "mount_target_ids" {
  description = "Map of subnet ID to mount target ID."
  value       = { for k, v in aws_efs_mount_target.this : k => v.id }
}

output "access_point_ids" {
  description = "Map of access point name to ID."
  value       = { for k, v in aws_efs_access_point.this : k => v.id }
}

output "access_point_arns" {
  description = "Map of access point name to ARN."
  value       = { for k, v in aws_efs_access_point.this : k => v.arn }
}
