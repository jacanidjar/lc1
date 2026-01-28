# Variables are kept minimal as most logic is in locals
# Variáveis mantidas no mínimo, pois a lógica está em locals
variable "container_image" {
  description = "The Docker image to deploy" # A imagem Docker para deploy
  type        = string
  default     = "nginx:latest" # Placeholder, overwritten by CI/CD
}
