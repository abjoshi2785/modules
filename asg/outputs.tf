output "autoscaling_group_name" {
  description = "Auto Scaling Group name."
  value       = aws_autoscaling_group.this.name
}

output "autoscaling_group_arn" {
  description = "Auto Scaling Group ARN."
  value       = aws_autoscaling_group.this.arn
}

output "launch_template_id" {
  description = "Launch template ID."
  value       = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template."
  value       = aws_launch_template.this.latest_version
}

output "availability_zones" {
  description = "Availability zones used by the Auto Scaling Group."
  value       = aws_autoscaling_group.this.availability_zones
}
