# AWS WAF v2 Module

WAFv2 Web ACL with AWS managed rule groups, rate limiting, IP allow/deny lists, and CloudWatch logging. Supports both REGIONAL (ALB, API Gateway) and CLOUDFRONT scopes.

## Features

- Four AWS managed rule groups: Common, Known Bad Inputs, IP Reputation, SQLi
- Per-IP rate limiting (configurable threshold per 5-minute window)
- IP allowlist (evaluated before all other rules — never blocked)
- IP denylist (unconditional block)
- Optional ALB association
- WAF logs shipped to CloudWatch with configurable retention

## Usage

### Attached to an ALB

```hcl
module "waf" {
  source = "../../modules/waf"

  name  = "myapp-production"
  scope = "REGIONAL"

  alb_arn = module.alb.load_balancer_arn

  enable_common_rule_set    = true
  enable_known_bad_inputs   = true
  enable_ip_reputation_list = true
  enable_sqli_rules         = true

  rate_limit = 2000  # requests per IP per 5 minutes

  allowed_ip_cidrs = ["10.8.0.0/16"]  # VPN — never rate-limited or blocked
  blocked_ip_cidrs = []

  enable_logging     = true
  log_retention_days = 90

  tags = {
    Environment = "production"
    Project     = "myapp"
    ManagedBy   = "terraform"
  }
}
```

### Scoped to CloudFront (must deploy in us-east-1)

```hcl
module "waf_global" {
  source = "../../modules/waf"

  name  = "myapp-cloudfront"
  scope = "CLOUDFRONT"  # CloudFront WAFs must be in us-east-1

  enable_common_rule_set    = true
  enable_ip_reputation_list = true
  rate_limit                = 5000

  tags = { Environment = "production" }
}

resource "aws_cloudfront_distribution" "this" {
  web_acl_id = module.waf_global.web_acl_arn
  # ...
}
```

## Rule Priority Order

| Priority | Rule | Action |
|----------|------|--------|
| 5 | IP Allowlist | Allow (if configured) |
| 10 | AWSManagedRulesCommonRuleSet | Block matching |
| 20 | AWSManagedRulesKnownBadInputsRuleSet | Block matching |
| 30 | AWSManagedRulesAmazonIpReputationList | Block matching |
| 40 | AWSManagedRulesSQLiRuleSet | Block matching |
| 50 | Rate Limit | Block over threshold |
| 60 | IP Denylist | Block (if configured) |

Lower number = evaluated first. The allowlist (priority 5) ensures trusted IPs are never caught by managed rules or rate limiting.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | string | required | Web ACL name |
| `scope` | string | `"REGIONAL"` | `REGIONAL` or `CLOUDFRONT` |
| `default_action` | string | `"allow"` | `allow` or `block` for unmatched requests |
| `alb_arn` | string | `""` | ALB ARN to associate (REGIONAL only) |
| `enable_common_rule_set` | bool | `true` | AWSManagedRulesCommonRuleSet |
| `enable_known_bad_inputs` | bool | `true` | AWSManagedRulesKnownBadInputsRuleSet |
| `enable_ip_reputation_list` | bool | `true` | AWSManagedRulesAmazonIpReputationList |
| `enable_sqli_rules` | bool | `true` | AWSManagedRulesSQLiRuleSet |
| `rate_limit` | number | `2000` | Requests per IP per 5 min (0 = disabled) |
| `blocked_ip_cidrs` | list(string) | `[]` | CIDRs to unconditionally block |
| `allowed_ip_cidrs` | list(string) | `[]` | CIDRs to unconditionally allow |
| `enable_logging` | bool | `true` | Send logs to CloudWatch |
| `log_retention_days` | number | `90` | Log retention in days |
| `tags` | map(string) | `{}` | Tags applied to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `web_acl_arn` | Web ACL ARN (pass to CloudFront or use for manual association) |
| `web_acl_id` | Web ACL ID |
| `web_acl_capacity` | WCU capacity consumed (max 1500 for REGIONAL) |
| `log_group_arn` | CloudWatch log group ARN |
| `blocked_ip_set_arn` | Blocked IP set ARN |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |
