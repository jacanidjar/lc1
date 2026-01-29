################################################################################
# Kubernetes Manifests (Managed by Terraform)
################################################################################

# We use the standard 'kubernetes_manifest' resource to apply the YAMLs.
# Note: The provider must wait for the EKS cluster to be ready.

resource "kubernetes_manifest" "deployment" {
  depends_on = [module.eks]

  manifest = yamldecode(replace(
    file("${path.module}/../k8s/deployment.yaml"),
    "REPLACE_WITH_ECR_IMAGE_URL",
    var.app_image
  ))
}

resource "kubernetes_manifest" "service" {
  depends_on = [module.eks]

  manifest = yamldecode(file("${path.module}/../k8s/service.yaml"))
}

resource "kubernetes_manifest" "ingress" {
  depends_on = [module.eks]

  manifest = yamldecode(file("${path.module}/../k8s/ingress.yaml"))
}

resource "kubernetes_namespace" "app_prod" {
  depends_on = [module.eks]

  metadata {
    name = "app-prod"
  }
}
