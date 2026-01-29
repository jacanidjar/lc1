variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "ledn-cluster"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "candidate_name" {
  description = "Candidate name for tags"
  type        = string
  default     = "Luis-Fernando"
}

variable "github_repo" {
  description = "GitHub Repository (Format: User/Repo)"
  type        = string
  default     = "jacanidjar/lc1"
}

variable "app_image" {
  description = "Docker image URL for the application"
  type        = string
  default     = "nginx:latest" # Default for initial bootstrap
}
