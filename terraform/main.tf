terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path    = pathexpand("~/.kube/devops-lab-terraform.config")
  config_context = "kind-devops-lab"
}

resource "kubernetes_namespace_v1" "lab" {
  metadata {
    name = "terraform-lab"
  }
}
resource "kubernetes_deployment_v1" "health_service" {
  metadata {
    name      = "health-service"
    namespace = kubernetes_namespace_v1.lab.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "health-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "health-service"
        }
      }

      spec {
        container {
          name              = "health-service"
          image             = "devops-health-service:local"
          image_pull_policy = "Never"

          port {
            container_port = 8080
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }

            period_seconds = 5
          }
        }
      }
    }
  }
}
