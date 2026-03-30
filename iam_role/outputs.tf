output "id" {
  description = "Role id."
  value       = aws_iam_role.this.id
}

output "name" {
  description = "Role name."
  value       = aws_iam_role.this.name
}

output "arn" {
  description = "Role ARN."
  value       = aws_iam_role.this.arn
}

output "instance_profile_name" {
  description = "Instance profile name (null if not created)."
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

output "instance_profile_arn" {
  description = "Instance profile ARN (null if not created)."
  value       = try(aws_iam_instance_profile.this[0].arn, null)
}

output "permissions_boundary" {
  description = "Permissions boundary attached to the role (null if not set)."
  value       = aws_iam_role.this.permissions_boundary
}
