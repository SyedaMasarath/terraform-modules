variable "name" {
  description = "Name for the Web ACL and all associated resources"
  type        = string
}

variable "scope" {
  description = "Scope of the WAF: REGIONAL (for ALB, API Gateway) or CLOUDFRONT (must be deployed in us-east-1)"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "scope must be REGIONAL or CLOUDFRONT."
  }
}

variable "default_action" {
  description = "Default action when no rule matches: allow or block"
  type        = string
  default     = "allow"
  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "default_action must be allow or block."
  }
}

variable "alb_arn" {
  description = "ARN of the ALB to associate the Web ACL with. Only valid for REGIONAL scope. Leave empty to skip association."
  type        = string
  default     = ""
}

# ── Managed rule groups ────────────────────────────────────────────────────────

variable "enable_common_rule_set" {
  description = "Enable AWSManagedRulesCommonRuleSet (XSS, LFI, RFI, size constraints)"
  type        = bool
  default     = true
}

variable "enable_known_bad_inputs" {
  description = "Enable AWSManagedRulesKnownBadInputsRuleSet (Log4Shell, SSRF, Spring4Shell)"
  type        = bool
  default     = true
}

variable "enable_ip_reputation_list" {
  description = "Enable AWSManagedRulesAmazonIpReputationList (bots, scanners, TOR exit nodes)"
  type        = bool
  default     = true
}

variable "enable_sqli_rules" {
  description = "Enable AWSManagedRulesSQLiRuleSet"
  type        = bool
  default     = true
}

# ── Rate limiting ──────────────────────────────────────────────────────────────

variable "rate_limit" {
  description = "Maximum requests per IP per 5-minute window before blocking. Set to 0 to disable."
  type        = number
  default     = 2000
  validation {
    condition     = var.rate_limit >= 0
    error_message = "rate_limit must be 0 (disabled) or a positive integer."
  }
}

# ── IP lists ───────────────────────────────────────────────────────────────────

variable "blocked_ip_cidrs" {
  description = "List of IPv4 CIDRs to unconditionally block"
  type        = list(string)
  default     = []
}

variable "allowed_ip_cidrs" {
  description = "List of IPv4 CIDRs to unconditionally allow (evaluated before all other rules)"
  type        = list(string)
  default     = []
}

# ── Logging ────────────────────────────────────────────────────────────────────

variable "enable_logging" {
  description = "Send WAF logs to a CloudWatch log group (name is auto-prefixed with 'aws-waf-logs-' per AWS requirement)"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
