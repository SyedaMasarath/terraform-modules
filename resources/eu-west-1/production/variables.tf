variable "project" {
  description = "Project name used in resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 3
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
  default     = 3
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways (3 for one-per-AZ HA)"
  type        = number
  default     = 3
}

# EKS
variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "eks_public_access_cidrs" {
  description = "CIDRs allowed to reach the EKS public API endpoint"
  type        = list(string)
}

variable "app_node_instance_types" {
  description = "EC2 instance types for the application node group"
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "app_node_desired" {
  description = "Desired number of application nodes"
  type        = number
  default     = 3
}

variable "app_node_min" {
  description = "Minimum number of application nodes"
  type        = number
  default     = 3
}

variable "app_node_max" {
  description = "Maximum number of application nodes"
  type        = number
  default     = 10
}

# RDS
variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r7g.large"
}

variable "db_instances" {
  description = "Number of Aurora cluster instances"
  type        = number
  default     = 2
}
