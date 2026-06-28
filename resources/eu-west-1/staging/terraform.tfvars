project     = "myapp"
environment = "staging"
aws_region  = "eu-west-1"

# VPC — non-overlapping with us-east-1 for cross-region peering readiness
vpc_cidr             = "10.11.0.0/16"
public_subnet_count  = 3
private_subnet_count = 3
nat_gateway_count    = 1

# EKS — SPOT nodes for cost savings in staging
kubernetes_version      = "1.29"
eks_public_access_cidrs = ["10.8.0.0/16"] # replace with your VPN CIDR
app_node_instance_types = ["m5.large", "m5a.large", "m4.large"]
app_node_desired        = 2
app_node_min            = 2
app_node_max            = 6
