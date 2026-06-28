output "load_balancer_arn" {
  description = "ARN of the created ALB."
  value       = aws_lb.this.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the created ALB."
  value       = aws_lb.this.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the created ALB."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the created target group."
  value       = aws_lb_target_group.this.arn
}

output "listener_arns" {
  description = "ARNs of created listeners."
  value       = concat([aws_lb_listener.http.arn], var.create_https_listener ? [aws_lb_listener.https[0].arn] : [])
}
