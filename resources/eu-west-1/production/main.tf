locals {
  common_tags = {
    Environment = var.environment
    Region      = var.aws_region
    Project     = var.project
    ManagedBy   = "terraform"
    Repository  = "SyedaMasarath/terraform-modules"
  }
}

module "vpc" {
  source = "../../../modules/vpc"

  name_prefix          = "${var.project}-${var.environment}"
  vpc_cidr             = var.vpc_cidr
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  enable_nat_gateway   = true
  nat_gateway_count    = var.nat_gateway_count

  public_subnet_tags = {
    "kubernetes.io/role/elb"                                  = "1"
    "kubernetes.io/cluster/${var.project}-${var.environment}" = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                         = "1"
    "kubernetes.io/cluster/${var.project}-${var.environment}" = "shared"
  }

  tags = local.common_tags
}

module "eks" {
  source = "../../../modules/eks"

  cluster_name       = "${var.project}-${var.environment}"
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  endpoint_public_access = true
  public_access_cidrs    = var.eks_public_access_cidrs

  app_node_instance_types = var.app_node_instance_types
  app_node_capacity_type  = "ON_DEMAND"
  app_node_desired        = var.app_node_desired
  app_node_min            = var.app_node_min
  app_node_max            = var.app_node_max

  tags = local.common_tags
}

module "rds" {
  source = "../../../modules/rds"

  identifier    = "${var.project}-${var.environment}"
  database_name = var.db_name
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.private_subnet_ids
  kms_key_arn   = module.eks.kms_key_arn

  allowed_sg_ids = [module.eks.node_security_group_id]

  instance_class      = var.db_instance_class
  instances           = var.db_instances
  deletion_protection = true

  tags = local.common_tags
}
