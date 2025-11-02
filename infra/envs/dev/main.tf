
# VPC in primary region
module "vpc_primary" {
  source       = "../../modules/vpc"
  providers    = { aws = aws }
  project_name = var.project_name
  region       = var.primary_region
}

# VPC in secondary region
module "vpc_secondary" {
  source       = "../../modules/vpc"
  providers    = { aws = aws.secondary }
  project_name = var.project_name
  region       = var.secondary_region
}

# EKS in primary region
module "eks_primary" {
  source         = "../../modules/eks"
  providers      = { aws = aws }
  project_name   = var.project_name
  region         = var.primary_region
  subnet_ids     = module.vpc_primary.private_subnet_ids
  vpc_id         = module.vpc_primary.vpc_id
}

# EKS in secondary region
module "eks_secondary" {
  source         = "../../modules/eks"
  providers      = { aws = aws.secondary }
  project_name   = var.project_name
  region         = var.secondary_region
  subnet_ids     = module.vpc_secondary.private_subnet_ids
  vpc_id         = module.vpc_secondary.vpc_id
}

module "node_group_primary" {
  source        = "../../modules/node_group"
  providers     = { aws = aws }
  project_name  = var.project_name
  region        = var.primary_region
  cluster_name  = module.eks_primary.cluster_name
  subnet_ids    = module.vpc_primary.private_subnet_ids
  node_role_arn = module.eks_primary.node_role_arn
}

module "node_group_secondary" {
  source        = "../../modules/node_group"
  providers     = { aws = aws.secondary }
  project_name  = var.project_name
  region        = var.secondary_region
  cluster_name  = module.eks_secondary.cluster_name
  subnet_ids    = module.vpc_secondary.private_subnet_ids
  node_role_arn = module.eks_secondary.node_role_arn
}
