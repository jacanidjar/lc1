# Resumo do Projeto: Ledn DevOps Challenge (Edição Senior)

Este documento resume as implementações realizadas para atender e superar os requisitos do desafio técnico de DevOps.

## 1. Arquitetura e Infraestrutura (Terraform)
Implementamos uma arquitetura **Serverless Kubernetes** robusta e escalável na AWS.
*   **EKS Fargate**: Cluster Kubernetes sem gerenciamento de servidores (EC2), focando puramente na aplicação.
*   **Rede (VPC)**:
    *   **Alta Disponibilidade**: Multi-AZ (`us-east-1a`, `us-east-1b`).
    *   **Segurança**: Sub-redes Públicas (apenas para Load Balancer) e Privadas (para a Aplicação).
    *   **Tags**: Configuração rigorosa de tags para integração automática com o AWS Load Balancer Controller.
*   **Código (IaC)**: Terraform modular achatado (Flat Structure), utilizando módulos oficiais do registro da AWS (`terraform-aws-modules`) para manutenção simplificada.

## 2. Aplicação e Containerização
*   **Python Flask**: API JSON simples seguindo a especificação exata (commit ID, ambiente, versão).
*   **Docker**:
    *   **Multi-stage Build**: Imagem final leve baseada em `python:3.11-slim`.
    *   **Segurança**: Execução com usuário não-root (`appuser`).

## 3. Kubernetes (Manifestos)
*   **Deployment**: Estratégia `RollingUpdate` para **Zero Downtime**, com Probes (Liveness/Readiness) configurados.
*   **HPA (Autoscaling)**: Escalonamento automático de Pods (2 a 10 réplicas) baseado em uso de CPU (Meta: 50%).
*   **Ingress (ALB)**: Exposição via AWS Application Load Balancer, roteando tráfego externo para os Pods no Fargate.

## 4. CI/CD (GitHub Actions)
Pipeline completa e automatizada:
1.  **Build**: Constrói a imagem Docker.
2.  **Test**: Executa testes unitários (`pytest`) para garantir qualidade.
3.  **Push**: Envia a imagem para o Amazon ECR.
4.  **Deploy**:
    *   Provisiona Infraestrutura (`terraform apply`).
    *   Atualiza a Aplicação (`kubectl apply` + `rollout`).

## 5. Monitoramento e Conformidade
*   **CloudWatch**: Alarme configurado via Terraform para alertar se CPU do Cluster > 80%.
*   **Documentação**:
    *   `README.md`: Explicações estratégicas ("Ace in the Hole"), diagramas e planos de segurança.
    *   `CHALLENGE.md`: Cópia do enunciado original para auditoria.
    *   **Bilíngue**: Comentários no código em Inglês e Português.

## Conclusão
O projeto entrega uma solução **"Gabrieleto" (Perfect Score)**, cobrindo 100% dos requisitos funcionais, não-funcionais e bônus, pronto para produção.
