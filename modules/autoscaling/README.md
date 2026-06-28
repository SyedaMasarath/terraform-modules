# AWS Auto Scaling Group Module

This module provisions an EC2 Auto Scaling Group using a launch template and supports production-grade scaling across multiple AZs.

## Features

- Launch template backed EC2 Auto Scaling Group
- High availability across multiple subnets/AZs
- Managed instance profile and security group support
- Configurable health checks, cooldowns, and termination policies
- Optional ALB target group attachment
- Root EBS volume customization

## Usage

```hcl
module "app_asg" {
  source              = "../terraform-modules/autoscaling"
  name_prefix         = "myapp"
  ami_id              = "ami-0abcdef1234567890"
  instance_type       = "t3.medium"
  iam_instance_profile = "myapp-instance-profile"
  security_group_ids  = [module.app_sg.security_group_id]
  subnet_ids          = module.vpc.private_subnet_ids
  user_data           = file("startup.sh")

  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

## Inputs

- `name_prefix` - Required prefix for ASG and launch template names.
- `ami_id` - Required AMI ID.
- `instance_type` - EC2 instance type.
- `key_name` - Optional EC2 key pair name.
- `iam_instance_profile` - Optional IAM instance profile name.
- `security_group_ids` - Security groups for the instances.
- `subnet_ids` - Required list of subnet IDs spanning Availability Zones.
- `user_data` - Optional bootstrap script.
- `min_size` - Minimum ASG size.
- `max_size` - Maximum ASG size.
- `desired_capacity` - Desired ASG size.
- `health_check_type` - EC2 or ELB health check type.
- `health_check_grace_period` - Health check grace period.
- `default_cooldown` - Cooldown period between scaling actions.
- `force_delete` - Force deletion of the ASG with instances.
- `termination_policies` - ASG termination policies.
- `metrics_granularity` - Metrics collection granularity.
- `target_group_arns` - Optional ALB target groups.
- `ebs_volume_size` - Root volume size.
- `ebs_volume_type` - Root volume type.
- `ebs_iops` - IOPS for gp3 volumes.
- `ebs_throughput` - Throughput for gp3 volumes.
- `tags` - Tags assigned to instances and the ASG.

## Outputs

- `autoscaling_group_name` - ASG name.
- `autoscaling_group_arn` - ASG ARN.
- `launch_template_id` - Launch template ID.
- `launch_template_latest_version` - Latest launch template version.
- `subnet_ids` - Subnet IDs used by the ASG.
- `security_group_ids` - Security groups used by the launch template.
