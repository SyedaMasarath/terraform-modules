#--------------------------------------------------------------
# Example 1: Basic VPC with 3 public and 3 private subnets
#--------------------------------------------------------------
module "vpc_basic" {
  source = "../"

  name_prefix = "my-app"
  vpc_cidr    = "10.0.0.0/16"

  public_subnet_count  = 3
  private_subnet_count = 3

  tags = {
    Environment = "production"
    Project     = "my-application"
    ManagedBy   = "terraform"
  }
}

#--------------------------------------------------------------
# Example 2: High Availability VPC with NAT Gateway per AZ
#--------------------------------------------------------------
module "vpc_ha" {
  source = "../"

  name_prefix = "my-app-ha"
  vpc_cidr    = "10.1.0.0/16"

  public_subnet_count  = 3
  private_subnet_count = 3

  # Create one NAT Gateway per public subnet for HA
  enable_nat_gateway = true
  nat_gateway_count  = 3

  tags = {
    Environment = "production"
    Project     = "high-availability-app"
    ManagedBy   = "terraform"
  }
}

#--------------------------------------------------------------
# Example 3: Cost-Optimized VPC with Single NAT Gateway
#--------------------------------------------------------------
module "vpc_cost_optimized" {
  source = "../"

  name_prefix = "my-app-dev"
  vpc_cidr    = "10.2.0.0/16"

  public_subnet_count  = 2
  private_subnet_count = 2

  # Single NAT Gateway for cost savings
  enable_nat_gateway = true
  nat_gateway_count  = 1

  tags = {
    Environment = "development"
    Project     = "cost-optimized-app"
    ManagedBy   = "terraform"
  }
}

#--------------------------------------------------------------
# Example 4: VPC with Custom CIDR Sizing
#--------------------------------------------------------------
module "vpc_custom_cidr" {
  source = "../"

  name_prefix = "my-app-custom"
  vpc_cidr    = "10.3.0.0/16"

  public_subnet_count  = 4
  private_subnet_count = 4

  # Public subnets will be /20 (4096 IPs each)
  public_subnet_cidr_bits = 4

  # Private subnets will be /20 (4096 IPs each)
  private_subnet_cidr_bits = 4

  enable_nat_gateway = true
  nat_gateway_count  = 2

  tags = {
    Environment = "production"
    Project     = "large-scale-app"
    ManagedBy   = "terraform"
  }
}

#--------------------------------------------------------------
# Example 5: VPC with Flow Logs
#--------------------------------------------------------------
module "vpc_with_flow_logs" {
  source = "../"

  name_prefix = "my-app-monitored"
  vpc_cidr    = "10.4.0.0/16"

  public_subnet_count  = 3
  private_subnet_count = 3

  enable_nat_gateway = true
  nat_gateway_count  = 1

  # Enable VPC Flow Logs
  enable_flow_logs            = true
  flow_logs_destination_type  = "cloud-watch-logs"
  flow_logs_destination_arn   = aws_cloudwatch_log_group.vpc_flow_logs.arn
  flow_logs_iam_role_arn      = aws_iam_role.vpc_flow_logs.arn
  flow_logs_traffic_type      = "ALL"

  tags = {
    Environment = "production"
    Project     = "monitored-app"
    ManagedBy   = "terraform"
  }
}

# CloudWatch Log Group for Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 7
}

# IAM Role for Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

#--------------------------------------------------------------
# Example 6: VPC with Kubernetes Tags
#--------------------------------------------------------------
module "vpc_eks" {
  source = "../"

  name_prefix = "my-eks-cluster"
  vpc_cidr    = "10.5.0.0/16"

  public_subnet_count  = 3
  private_subnet_count = 3

  enable_nat_gateway = true
  nat_gateway_count  = 3

  # Tags for EKS cluster
  tags = {
    Environment                              = "production"
    Project                                  = "eks-cluster"
    "kubernetes.io/cluster/my-eks-cluster"   = "shared"
  }

  # Additional tags for public subnets (EKS load balancers)
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  # Additional tags for private subnets (EKS internal load balancers)
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

#--------------------------------------------------------------
# Outputs
#--------------------------------------------------------------
output "basic_vpc_id" {
  description = "Basic VPC ID"
  value       = module.vpc_basic.vpc_id
}

output "ha_vpc_public_subnets" {
  description = "HA VPC Public Subnet IDs"
  value       = module.vpc_ha.public_subnet_ids
}

output "cost_optimized_nat_ip" {
  description = "Cost-optimized VPC NAT Gateway IP"
  value       = module.vpc_cost_optimized.nat_gateway_public_ips
}
