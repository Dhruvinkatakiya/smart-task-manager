###############################################################################
# Terraform Variables for Smart Task Manager
###############################################################################

variable "namespace" {
  description = "Kubernetes namespace for application deployment"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "replicas" {
  description = "Number of replicas for each microservice"
  type        = number
  default     = 1
}

variable "image_pull_policy" {
  description = "Image pull policy for Kubernetes pods"
  type        = string
  default     = "Never" # Use "Always" for remote registries
}

# Kubernetes Configuration
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = "minikube"
}

# Docker Images
variable "auth_image" {
  description = "Docker image for auth service"
  type        = string
  default     = "auth-service:latest"
}

variable "task_image" {
  description = "Docker image for task service"
  type        = string
  default     = "task-service:latest"
}

variable "board_image" {
  description = "Docker image for board service"
  type        = string
  default     = "board-service:latest"
}

# Database Configuration
variable "mongo_uri" {
  description = "MongoDB connection URI"
  type        = string
  default     = "mongodb://mongo:27017/smart_task_manager"
  sensitive   = true
}

# Security
variable "jwt_secret" {
  description = "JWT secret for authentication"
  type        = string
  default     = "1c14e03fbe93ef776adf802f537334edb660dc223afd64cbc3b1b61be8873c65"
  sensitive   = true
}

# Ingress Configuration
variable "ingress_host" {
  description = "Ingress hostname"
  type        = string
  default     = "localhost"
}

variable "enable_tls" {
  description = "Enable TLS for ingress"
  type        = bool
  default     = false
}


