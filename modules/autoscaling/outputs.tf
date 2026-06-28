output "autoscaling_group_name" {
  description = "Name of the created Auto Scaling Group."
  value       = aws_autoscaling_group.this.name
}

output "autoscaling_group_arn" {
  description = "ARN of the created Auto Scaling Group."
  value       = aws_autoscaling_group.this.arn
}

output "launch_template_id" {
  description = "ID of the created launch template."
  value       = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  description = "Latest launch template version used by the ASG."
  value       = aws_launch_template.this.latest_version
}

output "subnet_ids" {
  description = "Subnet IDs assigned to the ASG."
  value       = aws_autoscaling_group.this.vpc_zone_identifier
}

output "security_group_ids" {
  description = "Security groups associated with instances launched by the ASG."
  value       = aws_launch_template.this.vpc_security_group_ids
}
