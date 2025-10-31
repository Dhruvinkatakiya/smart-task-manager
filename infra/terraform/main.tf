###############################################################################
# Main Terraform Configuration for Smart Task Manager
# Manages: Namespace, Secrets, MongoDB, Microservices, Ingress
###############################################################################

# Use existing default namespace
# Note: default namespace already exists in Kubernetes cluster
# resource "kubernetes_namespace" "app_ns" {
#   metadata {
#     name = var.namespace
#     labels = {
#       name        = var.namespace
#       environment = var.environment
#       managed-by  = "terraform"
#     }
#   }
# }

###############################################################################
# Secrets Management
###############################################################################

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "smart-secrets"
    namespace = var.namespace
  }

  data = {
    MONGO_URI  = base64encode(var.mongo_uri)
    JWT_SECRET = base64encode(var.jwt_secret)
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "mongo_config" {
  metadata {
    name      = "mongo-config"
    namespace = var.namespace
  }

  data = {
    MONGO_URI = var.mongo_uri
  }
}

###############################################################################
# MongoDB Deployment & Service
###############################################################################

resource "kubernetes_deployment" "mongo" {
  metadata {
    name      = "mongo"
    namespace = var.namespace
    labels    = { app = "mongo" }
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "mongo" }
    }

    template {
      metadata {
        labels = { app = "mongo" }
      }

      spec {
        container {
          name  = "mongo"
          image = "mongo:6.0"

          port {
            container_port = 27017
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }

          volume_mount {
            name       = "mongo-storage"
            mount_path = "/data/db"
          }
        }

        volume {
          name = "mongo-storage"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "mongo" {
  metadata {
    name      = "mongo"
    namespace = var.namespace
  }

  spec {
    selector = { app = "mongo" }

    port {
      port        = 27017
      target_port = 27017
    }

    type = "ClusterIP"
  }
}

###############################################################################
# Auth Service Deployment & Service
###############################################################################

resource "kubernetes_deployment" "auth" {
  metadata {
    name      = "auth-service"
    namespace = var.namespace
    labels    = { app = "auth-service", tier = "backend" }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = "auth-service" }
    }

    template {
      metadata {
        labels = { app = "auth-service" }
      }

      spec {
        container {
          name              = "auth-service"
          image             = var.auth_image
          image_pull_policy = var.image_pull_policy

          port {
            container_port = 8000
          }

          env {
            name  = "NODE_ENV"
            value = "production"
          }

          env {
            name = "MONGO_URI"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.mongo_config.metadata[0].name
                key  = "MONGO_URI"
              }
            }
          }

          env {
            name = "JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secrets.metadata[0].name
                key  = "JWT_SECRET"
              }
            }
          }

          env {
            name  = "PORT"
            value = "8000"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/api/auth/"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/api/auth/"
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.mongo]
}

resource "kubernetes_service" "auth" {
  metadata {
    name      = "auth-service"
    namespace = var.namespace
  }

  spec {
    selector = { app = "auth-service" }

    port {
      name        = "http"
      port        = 80
      target_port = 8000
    }

    type = "ClusterIP"
  }
}

###############################################################################
# Task Service Deployment & Service
###############################################################################

resource "kubernetes_deployment" "task" {
  metadata {
    name      = "task-service"
    namespace = var.namespace
    labels    = { app = "task-service", tier = "backend" }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = "task-service" }
    }

    template {
      metadata {
        labels = { app = "task-service" }
      }

      spec {
        container {
          name              = "task-service"
          image             = var.task_image
          image_pull_policy = var.image_pull_policy

          port {
            container_port = 5001
          }

          env {
            name  = "NODE_ENV"
            value = "production"
          }

          env {
            name = "MONGO_URI"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.mongo_config.metadata[0].name
                key  = "MONGO_URI"
              }
            }
          }

          env {
            name = "JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secrets.metadata[0].name
                key  = "JWT_SECRET"
              }
            }
          }

          env {
            name  = "PORT"
            value = "5001"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 5001
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 5001
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.mongo]
}

resource "kubernetes_service" "task" {
  metadata {
    name      = "task-service"
    namespace = var.namespace
  }

  spec {
    selector = { app = "task-service" }

    port {
      name        = "http"
      port        = 80
      target_port = 5001
    }

    type = "ClusterIP"
  }
}

###############################################################################
# Board Service Deployment & Service
###############################################################################

resource "kubernetes_deployment" "board" {
  metadata {
    name      = "board-service"
    namespace = var.namespace
    labels    = { app = "board-service", tier = "backend" }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = "board-service" }
    }

    template {
      metadata {
        labels = { app = "board-service" }
      }

      spec {
        container {
          name              = "board-service"
          image             = var.board_image
          image_pull_policy = var.image_pull_policy

          port {
            container_port = 8002
          }

          env {
            name  = "NODE_ENV"
            value = "production"
          }

          env {
            name = "MONGO_URI"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.mongo_config.metadata[0].name
                key  = "MONGO_URI"
              }
            }
          }

          env {
            name = "JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secrets.metadata[0].name
                key  = "JWT_SECRET"
              }
            }
          }

          env {
            name  = "PORT"
            value = "8002"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8002
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8002
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.mongo]
}

resource "kubernetes_service" "board" {
  metadata {
    name      = "board-service"
    namespace = var.namespace
  }

  spec {
    selector = { app = "board-service" }

    port {
      name        = "http"
      port        = 80
      target_port = 8002
    }

    type = "ClusterIP"
  }
}

###############################################################################
# Ingress Configuration
###############################################################################

resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name      = "smart-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/api/auth(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service.auth.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }

        path {
          path      = "/api/tasks(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service.task.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }

        path {
          path      = "/api/boards(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service.board.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.auth,
    kubernetes_service.task,
    kubernetes_service.board
  ]
}

