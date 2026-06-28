output "web_acl_arn" {
  description = "ARN of the Web ACL — pass to CloudFront distribution or use directly with ALB association"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_id" {
  description = "ID of the Web ACL"
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_capacity" {
  description = "Web ACL capacity units consumed (max 1500 for REGIONAL)"
  value       = aws_wafv2_web_acl.this.capacity
}

output "log_group_arn" {
  description = "CloudWatch log group ARN for WAF logs (null if logging is disabled)"
  value       = var.enable_logging ? aws_cloudwatch_log_group.waf[0].arn : null
}

output "blocked_ip_set_arn" {
  description = "ARN of the blocked IP set (null if no blocked CIDRs were provided)"
  value       = length(var.blocked_ip_cidrs) > 0 ? aws_wafv2_ip_set.blocked[0].arn : null
}
