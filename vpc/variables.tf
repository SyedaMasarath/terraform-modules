#--------------------------------------------------------------
# Required Variables
#--------------------------------------------------------------
variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

#--------------------------------------------------------------
# Subnet Configuration
#--------------------------------------------------------------
variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 3
  validation {
    condition     = var.public_subnet_count > 0 && var.public_subnet_count <= 10
    error_message = "Public subnet count must be between 1 and 10."
  }
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 3
  validation {
    condition     = var.private_subnet_count > 0 && var.private_subnet_count <= 10
    error_message = "Private subnet count must be between 1 and 10."
  }
}

variable "public_subnet_cidr_bits" {
  description = "Number of additional bits with which to extend the VPC CIDR for public subnets. For example, if given a prefix ending in /16 and a value of 4, the resulting subnet will have length /20"
  type        = number
  default     = 4
  validation {
    condition     = var.public_subnet_cidr_bits >= 1 && var.public_subnet_cidr_bits <= 16
    error_message = "CIDR bits must be between 1 and 16."
  }
}

variable "private_subnet_cidr_bits" {
  description = "Number of additional bits with which to extend the VPC CIDR for private subnets. For example, if given a prefix ending in /16 and a value of 4, the resulting subnet will have length /20"
  type        = number
  default     = 4
  validation {
    condition     = var.private_subnet_cidr_bits >= 1 && var.private_subnet_cidr_bits <= 16
    error_message = "CIDR bits must be between 1 and 16."
  }
}

#--------------------------------------------------------------
# DNS Configuration
#--------------------------------------------------------------
variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

#--------------------------------------------------------------
# Internet Gateway Configuration
#--------------------------------------------------------------
variable "create_igw" {
  description = "Controls if an Internet Gateway is created for public subnets"
  type        = bool
  default     = true
}

#--------------------------------------------------------------
# NAT Gateway Configuration
#--------------------------------------------------------------
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create. For high availability, set this to the number of public subnets. For cost savings, set to 1"
  type        = number
  default     = 1
  validation {
    condition     = var.nat_gateway_count > 0 && var.nat_gateway_count <= 10
    error_message = "NAT Gateway count must be between 1 and 10."
  }
}

#--------------------------------------------------------------
# Public Subnet Configuration
#--------------------------------------------------------------
variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the public subnet should be assigned a public IP address"
  type        = bool
  default     = true
}

#--------------------------------------------------------------
# VPC Flow Logs Configuration
#--------------------------------------------------------------
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_logs_destination_type" {
  description = "Type of flow log destination. Can be cloud-watch-logs or s3"
  type        = string
  default     = "cloud-watch-logs"
  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.flow_logs_destination_type)
    error_message = "Flow logs destination type must be either 'cloud-watch-logs' or 's3'."
  }
}

variable "flow_logs_destination_arn" {
  description = "ARN of the destination for VPC Flow Logs (CloudWatch Log Group or S3 Bucket)"
  type        = string
  default     = ""
}

variable "flow_logs_iam_role_arn" {
  description = "IAM role ARN for VPC Flow Logs (required when using CloudWatch Logs)"
  type        = string
  default     = ""
}

variable "flow_logs_traffic_type" {
  description = "Type of traffic to capture. Valid values: ACCEPT, REJECT, ALL"
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "Flow logs traffic type must be ACCEPT, REJECT, or ALL."
  }
}

#--------------------------------------------------------------
# Tags
#--------------------------------------------------------------
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default     = {}
}
