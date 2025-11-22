#--------------------------------------------------------------
# Example Variable Values
# Copy this file to terraform.tfvars and customize
#--------------------------------------------------------------

# Required Variables
name_prefix = "my-app-prod"
vpc_cidr    = "10.0.0.0/16"

# Subnet Configuration
public_subnet_count  = 3
private_subnet_count = 3

# CIDR sizing (4 = /20 subnets with 4096 IPs each)
public_subnet_cidr_bits  = 4
private_subnet_cidr_bits = 4

# NAT Gateway Configuration
enable_nat_gateway = true
nat_gateway_count  = 1  # Set to 3 for high availability (one per AZ)

# DNS Configuration
enable_dns_hostnames = true
enable_dns_support   = true

# Public IP Configuration
map_public_ip_on_launch = true

# VPC Flow Logs (optional)
enable_flow_logs = false
# flow_logs_destination_type = "cloud-watch-logs"
# flow_logs_destination_arn  = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpc/flow-logs"
# flow_logs_iam_role_arn     = "arn:aws:iam::123456789012:role/vpc-flow-logs-role"
# flow_logs_traffic_type     = "ALL"

# Tags
tags = {
  Environment = "production"
  Project     = "my-application"
  ManagedBy   = "terraform"
  Owner       = "platform-team"
  CostCenter  = "engineering"
}

# Additional subnet tags (useful for Kubernetes)
public_subnet_tags = {
  "kubernetes.io/role/elb" = "1"
  Tier                     = "public"
}

private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = "1"
  Tier                               = "private"
}
