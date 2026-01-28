# Local variables for configuration
# Variáveis locais para configuração
locals {
  name        = "ledn-cluster"
  environment = "prod"
  region      = var.region
  vpc_cidr    = "10.0.0.0/16"
  azs         = ["us-east-1a", "us-east-1b"]
}

variable "region" {
  default = "us-east-1"
}

# AWS Provider configuration
# Configuração do Provedor AWS
provider "aws" {
  region = local.region
}

# Kubernetes Provider for EKS
# Provedor Kubernetes para EKS
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Helm Provider for Charts
# Provedor Helm para Charts
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# --- VPC Module ---
# --- Módulo VPC ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # Enable NAT Gateway for private subnets
  # Habilita NAT Gateway para sub-redes privadas
  enable_nat_gateway = true
  single_nat_gateway = true # Cost Optimization / Otimização de Custo
  enable_vpn_gateway = false

  # CRITICAL: Tags for Load Balancer Controller
  # CRÍTICO: Tags para o Controlador do Load Balancer
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment = local.environment
    Project     = "LednChallenge"
  }
}

# --- EKS Module ---
# --- Módulo EKS ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.name
  cluster_version = "1.28"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Enable IRSA for AWS Load Balancer Controller
  # Habilita IRSA para o AWS Load Balancer Controller
  enable_irsa = true

  # Fargate Profiles for serverless compute
  # Perfis Fargate para computação serverless
  fargate_profiles = {
    main = {
      name = "main"
      selectors = [
        { namespace = "app-prod" },
        { namespace = "kube-system" },
        { namespace = "default" }
      ]
    }
  }

  tags = {
    Environment = local.environment
  }
}

# --- AWS Load Balancer Controller (Helm) ---
# --- Controlador AWS Load Balancer (Helm) ---
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}

# --- Monitoring: CloudWatch Alarm ---
# --- Monitoramento: Alarme CloudWatch ---
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "eks-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EKS" # Or ContainerInsights if enabled, using EKS placeholder for now
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EKS cluster CPU utilization"
  
  dimensions = {
    ClusterName = module.eks.cluster_name
  }
}
