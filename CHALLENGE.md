# Ledn DevOps Challenge

## Introduction
Thank you for your interest in working at Ledn. We’re looking forward to meeting you.
To guide our technical conversation, we’d like you to complete a small practical project.

The goal is to see how you think, how you structure infrastructure, and how you reason about trade-offs. This is not about building something “perfect”, but about showing your judgment.

## Overview
Design and implement a small, highly-available web service on AWS using Infrastructure as Code and containers.

## Requirements
### 1. Application
Simple HTTP service returning:
- “Hello World”
- Your name
- Environment name
- Build, version or commit ID
- Provide the Dockerfile.

### 2. Infrastructure (Terraform)
- VPC with at least 2 AZs
- Public or ALB-facing subnets
- Load balancer routing to your containerized service
- Compute of your choice: EC2, ECS, EKS, or Lambda with container
- Everything defined as IaC using Terraform (modular structure preferred)

### 3. CI/CD
A pipeline that:
- Builds & tests the application
- Builds & pushes the image to ECR (or alternative)
- Deploys the new version using Terraform or another method you justify

### 4. Monitoring & Scaling
- Basic monitoring (CloudWatch or equivalent): at least 1 metric, 1 alarm
- Autoscaling of the container based on CPU, requests, or another metric
- Brief explanation or screenshot of how you tested scaling

### 5. Deliverables
A Git repository containing:
- Application code + Dockerfile
- Terraform code
- CI/CD configuration
- A brief README with:
    - Architecture summary + tiny diagram
    - How to deploy & destroy
    - Design choices & trade-offs
    - Monitoring & scaling notes
    - Security improvement plan

### 6. Bonus (Optional)
- EKS deployment
- Lambda-based version
- Extra observability (dashboards, tracing)
