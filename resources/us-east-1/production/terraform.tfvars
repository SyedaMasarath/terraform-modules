project     = "myapp"
environment = "production"
aws_region  = "us-east-1"

# VPC — 3 NAT Gateways for one-per-AZ high availability
vpc_cidr             = "10.2.0.0/16"
public_subnet_count  = 3
private_subnet_count = 3
nat_gateway_count    = 3

# EKS — ON_DEMAND nodes for production reliability
kubernetes_version      = "1.29"
eks_public_access_cidrs = ["10.8.0.0/16"] # replace with your VPN CIDR
app_node_instance_types = ["m5.xlarge"]
app_node_desired        = 3
app_node_min            = 3
app_node_max            = 10

# RDS
db_name           = "myapp"
db_instance_class = "db.r7g.large"
db_instances      = 2

rotation_lambda_arn = "REPLACE-ME-rotation-lambda-arn"
