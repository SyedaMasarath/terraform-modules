resource "aws_lb" "this" {
  name                       = "${var.name_prefix}-alb"
  internal                   = var.internal
  load_balancer_type         = "application"
  subnets                    = var.subnets
  security_groups            = length(var.security_group_ids) > 0 ? var.security_group_ids : null
  ip_address_type            = var.ip_address_type
  enable_http2               = var.enable_http2
  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-alb"
    }
  )
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name_prefix}-tg"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = var.health_check.enabled
    path                = var.health_check.path
    port                = var.health_check.port
    protocol            = var.health_check.protocol
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    timeout             = var.health_check.timeout
    interval            = var.health_check.interval
    matcher             = var.health_check.matcher
  }

  tags = merge(
    var.tags,
    var.target_group_tags,
    {
      Name = "${var.name_prefix}-tg"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type = var.redirect_http_to_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.redirect_http_to_https ? [1] : []
      content {
        status_code = "HTTP_301"
        protocol    = "HTTPS"
        port        = tostring(var.https_port)
      }
    }

    dynamic "forward" {
      for_each = var.redirect_http_to_https ? [] : [1]
      content {
        target_group_arn = aws_lb_target_group.this.arn
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.create_https_listener ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
