###############################################################################
# Terraform Outputs for Smart Task Manager
###############################################################################

output "namespace" {
  description = "Kubernetes namespace where resources are deployed"
  value       = var.namespace
}

output "auth_service_name" {
  description = "Auth service name"
  value       = kubernetes_service.auth.metadata[0].name
}

output "task_service_name" {
  description = "Task service name"
  value       = kubernetes_service.task.metadata[0].name
}

output "board_service_name" {
  description = "Board service name"
  value       = kubernetes_service.board.metadata[0].name
}

output "mongo_service_name" {
  description = "MongoDB service name"
  value       = kubernetes_service.mongo.metadata[0].name
}

output "ingress_host" {
  description = "Ingress hostname"
  value       = var.ingress_host
}

output "auth_service_url" {
  description = "Auth service URL"
  value       = "http://${var.ingress_host}/api/auth"
}

output "task_service_url" {
  description = "Task service URL"
  value       = "http://${var.ingress_host}/api/tasks"
}

output "board_service_url" {
  description = "Board service URL"
  value       = "http://${var.ingress_host}/api/boards"
}

output "deployment_status" {
  description = "Deployment completion status"
  value       = "All services deployed successfully to namespace: ${var.namespace}"
}

