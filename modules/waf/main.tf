locals {
  tags = merge(var.tags, { Module = "waf" })
}

################################################################################
# IP Sets
################################################################################

resource "aws_wafv2_ip_set" "blocked" {
  count = length(var.blocked_ip_cidrs) > 0 ? 1 : 0

  name               = "${var.name}-blocked-ips"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_cidrs

  tags = local.tags
}

resource "aws_wafv2_ip_set" "allowed" {
  count = length(var.allowed_ip_cidrs) > 0 ? 1 : 0

  name               = "${var.name}-allowed-ips"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.allowed_ip_cidrs

  tags = local.tags
}

################################################################################
# Web ACL
################################################################################

resource "aws_wafv2_web_acl" "this" {
  name  = var.name
  scope = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  # IP allowlist — evaluated first so trusted IPs are never blocked
  dynamic "rule" {
    for_each = length(var.allowed_ip_cidrs) > 0 ? [1] : []
    content {
      name     = "IPAllowList"
      priority = 5
      action { allow {} }
      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.allowed[0].arn
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-ip-allowlist"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS Managed — Common Rule Set (XSS, LFI, RFI, etc.)
  dynamic "rule" {
    for_each = var.enable_common_rule_set ? [1] : []
    content {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 10
      override_action { none {} }
      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-common-rules"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS Managed — Known Bad Inputs (Log4Shell, SSRF probes, etc.)
  dynamic "rule" {
    for_each = var.enable_known_bad_inputs ? [1] : []
    content {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 20
      override_action { none {} }
      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-known-bad-inputs"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS Managed — Amazon IP Reputation List (bots, scanners, TOR exit nodes)
  dynamic "rule" {
    for_each = var.enable_ip_reputation_list ? [1] : []
    content {
      name     = "AWSManagedRulesAmazonIpReputationList"
      priority = 30
      override_action { none {} }
      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-ip-reputation"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS Managed — SQLi Rule Set
  dynamic "rule" {
    for_each = var.enable_sqli_rules ? [1] : []
    content {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 40
      override_action { none {} }
      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-sqli"
        sampled_requests_enabled   = true
      }
    }
  }

  # Rate limiting — blocks IPs that exceed threshold per 5-minute window
  dynamic "rule" {
    for_each = var.rate_limit > 0 ? [1] : []
    content {
      name     = "RateLimitRule"
      priority = 50
      action { block {} }
      statement {
        rate_based_statement {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-rate-limit"
        sampled_requests_enabled   = true
      }
    }
  }

  # IP denylist
  dynamic "rule" {
    for_each = length(var.blocked_ip_cidrs) > 0 ? [1] : []
    content {
      name     = "IPDenyList"
      priority = 60
      action { block {} }
      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.blocked[0].arn
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-ip-denylist"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }

  tags = local.tags
}

################################################################################
# ALB Association (REGIONAL scope only)
################################################################################

resource "aws_wafv2_web_acl_association" "this" {
  count = var.alb_arn != "" ? 1 : 0

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

################################################################################
# Logging
# Log group name MUST start with "aws-waf-logs-" per AWS requirement
################################################################################

resource "aws_cloudwatch_log_group" "waf" {
  count = var.enable_logging ? 1 : 0

  name              = "aws-waf-logs-${var.name}"
  retention_in_days = var.log_retention_days

  tags = local.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.enable_logging ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = ["${aws_cloudwatch_log_group.waf[0].arn}:*"]
}
