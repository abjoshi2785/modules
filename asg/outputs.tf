output "asg_name" {
  description = "Autoscaling group name."
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "Launch template id."
  value       = aws_launch_template.this.id
}
