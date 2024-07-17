
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo-nginx"
  }
}
resource "kubernetes_deployment" "demo" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.demo.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "DemoTestApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "DemoTestApp"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "demo" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.demo.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.demo.spec.0.template.0.metadata.0.labels.app
    }
    type = "NodePort"
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }
  }
}
