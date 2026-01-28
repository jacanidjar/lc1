output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  # Endpoint do plano de controle do EKS
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  # Nome do Cluster Kubernetes
  value       = module.eks.cluster_name
}

output "vpc_id" {
  description = "VPC ID"
  # ID da VPC
  value       = module.vpc.vpc_id
}
