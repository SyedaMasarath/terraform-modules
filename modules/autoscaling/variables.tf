variable "name_prefix" {
  description = "Name prefix used for the launch template and autoscaling group."
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch instances from."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the autoscaling group."
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access."
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for launched instances."
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = "Security groups attached to launched instances."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs where the ASG will place instances."
  type        = list(string)
}

variable "user_data" {
  description = "User data script for launched instances."
  type        = string
  default     = ""
}

variable "min_size" {
  description = "Minimum number of instances in the autoscaling group."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the autoscaling group."
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of instances in the autoscaling group."
  type        = number
  default     = 2
}

variable "health_check_type" {
  description = "Health check type for the autoscaling group."
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Grace period before autoscaling health checks are applied."
  type        = number
  default     = 300
}

variable "default_cooldown" {
  description = "Cooldown period between scaling activities."
  type        = number
  default     = 300
}

variable "force_delete" {
  description = "Whether to delete the ASG and all instances when the autoscaling group is destroyed."
  type        = bool
  default     = false
}

variable "termination_policies" {
  description = "Termination policies for the ASG."
  type        = list(string)
  default     = ["OldestInstance"]
}

variable "metrics_granularity" {
  description = "Metrics granularity for the ASG."
  type        = string
  default     = "1Minute"
}

variable "target_group_arns" {
  description = "Optional ALB target group ARNs to attach to the ASG."
  type        = list(string)
  default     = []
}

variable "ebs_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 50
}

variable "ebs_volume_type" {
  description = "Root EBS volume type."
  type        = string
  default     = "gp3"
}

variable "ebs_iops" {
  description = "Provisioned IOPS for gp3 volumes."
  type        = number
  default     = 3000
}

variable "ebs_throughput" {
  description = "Provisioned throughput for gp3 volumes."
  type        = number
  default     = 125
}

variable "tags" {
  description = "Tags applied to launched instances and ASG resources."
  type        = map(string)
  default     = {}
}
