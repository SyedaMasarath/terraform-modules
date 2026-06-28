# AWS Application Load Balancer Module

This module creates a production-ready Application Load Balancer with target group and listener support. It is designed for HA deployments across multiple Availability Zones and includes options for HTTPS termination and access logging.

## Features

- Application Load Balancer with cross-AZ high availability
- HTTP listener by default with optional HTTPS listener
- Redirect HTTP to HTTPS support
- Access logging support
- Configurable target group health checks
- Consistent tagging

## Usage

```hcl
module "alb" {
  source            = "../terraform-modules/alb"
  name_prefix       = "myapp"
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.public_subnet_ids
  security_group_ids = [module.app_sg.security_group_id]

  create_https_listener = true
  ssl_certificate_arn   = "arn:aws:acm:us-west-2:123456789012:certificate/abc123"
  redirect_http_to_https = true

  access_logs_enabled = true
  access_logs_bucket  = "myapp-alb-logs"

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

## Inputs

- `name_prefix` - Required name prefix.
- `vpc_id` - Required VPC ID.
- `subnets` - List of subnet IDs for the ALB.
- `security_group_ids` - Security groups for the ALB.
- `internal` - Whether the ALB is internal.
- `ip_address_type` - `ipv4` or `dualstack`.
- `enable_http2` - Enable HTTP/2.
- `idle_timeout` - Default 60 seconds.
- `enable_deletion_protection` - Protect against accidental deletion.
- `access_logs_enabled` - Enable ALB access logging.
- `access_logs_bucket` - S3 bucket for access logs.
- `target_group_protocol` - Target group protocol.
- `target_group_port` - Target group port.
- `target_type` - Target type for the target group.
- `health_check` - Health check settings.
- `create_https_listener` - Enable HTTPS listener.
- `ssl_certificate_arn` - ACM certificate ARN for HTTPS.
- `redirect_http_to_https` - Redirect HTTP to HTTPS.
- `http_port` - HTTP listener port.
- `https_port` - HTTPS listener port.
- `tags` - Tags for ALB resources.
- `target_group_tags` - Tags for the target group.

## Outputs

- `load_balancer_arn` - ALB ARN.
- `load_balancer_dns_name` - ALB DNS name.
- `load_balancer_zone_id` - ALB zone ID.
- `target_group_arn` - Target group ARN.
- `listener_arns` - Listener ARNs.
