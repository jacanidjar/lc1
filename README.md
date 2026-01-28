# Ledn DevOps Challenge (EKS Fargate Edition)

## 1. Project Overview
This repository contains a production-ready infrastructure for a Python web app on **AWS EKS (Kubernetes)** running on **Fargate (Serverless)**, managed by **Terraform** and **GitHub Actions**.

## 2. Architecture
- **EKS Cluster:** v1.28
- **Compute:** Fargate Only (No EC2 Nodes).
- **Networking:** Multi-AZ VPC (us-east-1a, us-east-1b).
- **Ingress:** AWS Application Load Balancer (ALB).

## 3. How to Deploy
1.  **Infrastructure:**
    ```bash
    cd terraform
    terraform init
    terraform apply
    ```
2.  **Application:**
    Push to `main` branch to trigger GitHub Actions.

## 4. Submission & Requirements Checklist
This project fulfills the **Ledn DevOps Challenge** requirements:

### ✅ Requirements Matched:
1.  **Application**: Flask App returning JSON + Dockerfile.
2.  **Infrastructure**: Terraform (Modular with Registry) + VPC (2 AZs/Private Subnets) + EKS + ALB.
3.  **CI/CD**: GitHub Actions (Build -> **Test** -> Push -> Deploy).
4.  **Monitoring**: CloudWatch Alarm (CPU).
5.  **Scaling**: HPA (Autoscaling) + Fargate.
6.  **Bonus**: **EKS Deployment** (Kubernetes) implemented!

### 📝 Submission Steps
1.  Repository is private.
2.  README includes architecture, deploy steps, and design choices.
3.  **Action Required**: Invite `Ledn-Reviewer` as a contributor.
4.  **Action Required**: Email Ledn confirming readiness.

## 5. The "Ace in the Hole" (Strategic Design Choices)

## 6. Monitoring & Scaling
### Monitoring (Monitoramento)
- **Tool**: AWS CloudWatch.
- **Metric**: CPU Utilization (Cluster Level).
- **Alarm**: `eks-high-cpu` triggers if Average CPU > 80% for 2 evaluation periods (Managed via Terraform).

### Scaling (Escalabilidade)
- **Horizontal Pod Autoscaler (HPA)**:
    - Scales Pods from **2 to 10** based on CPU utilization (Target: 50%).
    - Manifest: `k8s/hpa.yaml`.
- **Infrastructure**: Fargate automatically scales compute capacity as requested by the Scheduler.
- **How to Test Scaling (Como testar)**:
    1.  Deploy the infrastructure.
    2.  Run a load generator (e.g., `kubectl run -i --tty load-generator --image=busybox /bin/sh`).
    3.  Inside the pod, run a loop: `while true; do wget -q -O- http://flask-app-service.app-prod; done`.
    4.  Watch HPA: `kubectl get hpa -n app-prod -w`. You will see replicas increase as CPU rises.

## 6. Security Improvement Plan (Plano de Melhoria de Segurança)
While the current setup implements "Least Privilege", future improvements could include:
1.  **WAF (Web Application Firewall)**: Attach to ALB to block malicious traffic (SQLi, XSS).
2.  **Network Policies**: Restrict Pod-to-Pod communication within the cluster.
3.  **Image Scanning**: Enable ECR Scan on Push for vulnerability detection.
4.  **Secrets Management**: Integrate AWS Secrets Manager using "External Secrets Operator" instead of environment variables.

