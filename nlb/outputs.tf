output "arn" {
  description = "NLB ARN."
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "NLB DNS name."
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "NLB hosted zone ID."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "Target group ARN."
  value       = aws_lb_target_group.this.arn
}
