output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_public_ips" {
  description = "NAT Gateway public IPs (allowlist on firewall)"
  value       = module.vpc.nat_gateway_public_ips
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "db_cluster_endpoint" {
  description = "RDS Aurora writer endpoint"
  value       = module.rds.db_cluster_endpoint
}

output "db_reader_endpoint" {
  description = "RDS Aurora reader endpoint"
  value       = module.rds.db_reader_endpoint
}

output "db_credentials_secret_arn" {
  description = "Secrets Manager ARN for database credentials"
  value       = module.rds.db_credentials_secret_arn
}
