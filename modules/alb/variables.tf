variable "name_prefix" {
  description = "Name prefix for the load balancer resources."
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for the ALB. Use subnets across AZs for high availability."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the target group."
  type        = string
}

variable "security_group_ids" {
  description = "Security groups assigned to the ALB."
  type        = list(string)
  default     = []
}

variable "internal" {
  description = "Whether the ALB is internal-only."
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "IP address type for the load balancer."
  type        = string
  default     = "ipv4"
  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "ip_address_type must be ipv4 or dualstack."
  }
}

variable "enable_http2" {
  description = "Enable HTTP/2 on the ALB."
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Idle timeout in seconds for the ALB."
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB."
  type        = bool
  default     = false
}

variable "access_logs_enabled" {
  description = "Enable ALB access logs."
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket used for ALB access logs."
  type        = string
  default     = ""
  validation {
    condition     = !var.access_logs_enabled || length(trim(var.access_logs_bucket)) > 0
    error_message = "access_logs_bucket must be set when access_logs_enabled is true."
  }
}

variable "access_logs_prefix" {
  description = "Prefix for ALB access log objects."
  type        = string
  default     = "alb-logs/"
}

variable "target_group_protocol" {
  description = "Protocol for the target group."
  type        = string
  default     = "HTTP"
}

variable "target_group_port" {
  description = "Port for the target group."
  type        = number
  default     = 80
}

variable "target_type" {
  description = "Target type for the target group."
  type        = string
  default     = "instance"
}

variable "health_check" {
  description = "Health check configuration for the target group."
  type = object({
    enabled             = bool
    path                = string
    port                = string
    protocol            = string
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout             = number
    interval            = number
    matcher             = string
  })
  default = {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
}

variable "create_https_listener" {
  description = "Create an HTTPS listener for the ALB."
  type        = bool
  default     = false
}

variable "ssl_certificate_arn" {
  description = "ARN of the ACM certificate used for HTTPS. Required if create_https_listener is true."
  type        = string
  default     = ""
  validation {
    condition     = !var.create_https_listener || length(trim(var.ssl_certificate_arn)) > 0
    error_message = "ssl_certificate_arn must be set when create_https_listener is true."
  }
}

variable "redirect_http_to_https" {
  description = "Redirect HTTP traffic to HTTPS when the HTTPS listener is enabled."
  type        = bool
  default     = false
}

variable "http_port" {
  description = "Port for the HTTP listener."
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Port for the HTTPS listener."
  type        = number
  default     = 443
}

variable "tags" {
  description = "Additional tags for ALB resources."
  type        = map(string)
  default     = {}
}

variable "target_group_tags" {
  description = "Additional tags for the target group."
  type        = map(string)
  default     = {}
}
