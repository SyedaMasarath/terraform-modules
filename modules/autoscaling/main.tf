resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = length(trimspace(var.key_name)) > 0 ? var.key_name : null

  dynamic "iam_instance_profile" {
    for_each = length(trimspace(var.iam_instance_profile)) > 0 ? [1] : []
    content {
      name = var.iam_instance_profile
    }
  }

  vpc_security_group_ids = var.security_group_ids
  user_data              = length(trimspace(var.user_data)) > 0 ? base64encode(var.user_data) : null

  dynamic "block_device_mappings" {
    for_each = var.ebs_volume_size > 0 ? [1] : []
    content {
      device_name = "/dev/xvda"

      ebs {
        volume_size           = var.ebs_volume_size
        volume_type           = var.ebs_volume_type
        iops                  = var.ebs_volume_type == "gp3" ? var.ebs_iops : null
        throughput            = var.ebs_volume_type == "gp3" ? var.ebs_throughput : null
        delete_on_termination = true
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-instance"
      }
    )
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name_prefix}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  metrics_granularity       = var.metrics_granularity
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  termination_policies      = var.termination_policies

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
