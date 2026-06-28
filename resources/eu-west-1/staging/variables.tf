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
  description = "Number of NAT Gateways"
  type        = number
  default     = 1
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
  default     = ["m5.large", "m5a.large", "m4.large"]
}

variable "app_node_desired" {
  description = "Desired number of application nodes"
  type        = number
  default     = 2
}

variable "app_node_min" {
  description = "Minimum number of application nodes"
  type        = number
  default     = 2
}

variable "app_node_max" {
  description = "Maximum number of application nodes"
  type        = number
  default     = 6
}
