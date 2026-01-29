data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  vpc_cidr = var.vpc_cidr
  azs      = ["us-east-1a", "us-east-1b"]

  tags = {
    Candidate   = var.candidate_name
    Environment = var.environment
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = local.tags
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # Grant Admin permissions to the user running Terraform (to allow kubectl access)
  enable_cluster_creator_admin_permissions = true

  # Fargate Profiles
  fargate_profiles = {
    main = {
      name = "main"
      selectors = [
        { namespace = "default" },
        { namespace = "app-prod" },
        { namespace = "kube-system" }
      ]
    }
  }

  # IAM Roles for Service Accounts (IRSA)
  enable_irsa = true

  tags = local.tags
}

################################################################################
# ALB Controller IAM
################################################################################

module "load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name                              = "${var.cluster_name}-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

################################################################################
# GitHub Actions OIDC (Bootstrap)
################################################################################

module "iam_github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = "~> 5.30"
}

module "iam_github_oidc_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "~> 5.30"

  # Name of the role to be assumed by GitHub Actions
  name = "${var.cluster_name}-github-actions"

  # Trusting the specific repo
  subjects = ["${var.github_repo}:*"]

  # Permissions policies
  policies = {
    EKSAdmin = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    ECRAdmin = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
    VPCAdmin = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
    IAMAdmin = "arn:aws:iam::aws:policy/IAMFullAccess" # Needed to create IRSA roles (be careful in prod!)
  }

  tags = local.tags
}
