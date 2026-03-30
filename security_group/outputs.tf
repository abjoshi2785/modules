output "id" {
  description = "Security group id."
  value       = aws_security_group.this.id
}

output "arn" {
  description = "Security group arn."
  value       = aws_security_group.this.arn
}

output "name" {
  description = "Security group name (AWS generated due to name_prefix)."
  value       = aws_security_group.this.name
}
