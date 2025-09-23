# ArgoCD 배포 및 설정
# - ArgoCD 네임스페이스
# - ArgoCD Helm 차트 배포
# - ArgoCD 설정

# ArgoCD 네임스페이스 생성
resource "kubernetes_namespace" "argocd" {
  count = var.argocd_enabled ? 1 : 0
  
  metadata {
    name = var.argocd_namespace
    labels = {
      "app.kubernetes.io/name"     = "argocd"
      "app.kubernetes.io/instance" = "argocd"
    }
  }

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes,
    time_sleep.wait_for_nodes
  ]
}

# ArgoCD Helm 차트 배포
resource "helm_release" "argocd" {
  count = var.argocd_enabled ? 1 : 0

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = var.argocd_namespace

  # ArgoCD values 설정
  values = [
    yamlencode({
      global = {
        domain = "argocd.${var.gcp_project_id}.com"
      }
      
      server = {
        # ArgoCD 서버 설정 (Ingress Controller 사용)
        service = {
          type = "ClusterIP"
        }
        
        # Ingress 설정 (Private Cluster용)
        ingress = {
          enabled = true
          className = "nginx"
          annotations = {
            "kubernetes.io/ingress.class" = "nginx"
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
          }
          hosts = ["argocd.${var.gcp_project_id}.com"]
          tls = [{
            secretName = "argocd-server-tls"
            hosts = ["argocd.${var.gcp_project_id}.com"]
          }]
        }
        
        # 보안 설정
        config = {
          "admin.enabled" = "true"
          "admin.password" = var.argocd_admin_password
          "admin.passwordMtime" = "2024-01-01T00:00:00Z"
        }
        
        # 리소스 제한 (CPU 부족 문제 해결을 위한 증가)
        resources = {
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }
      
      # ArgoCD Controller 설정 (CPU 부족 문제 해결을 위한 증가)
      controller = {
        resources = {
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }
      
      # ArgoCD Repo Server 설정 (CPU 부족 문제 해결을 위한 증가)
      repoServer = {
        resources = {
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }
      
      # ArgoCD ApplicationSet Controller 설정 (CPU 부족 문제 해결을 위한 증가)
      applicationSet = {
        enabled = true
        resources = {
          limits = {
            cpu    = "300m"
            memory = "384Mi"
          }
          requests = {
            cpu    = "150m"
            memory = "192Mi"
          }
        }
      }
      
      # ArgoCD Redis 설정 (CPU 부족 문제 해결을 위한 증가)
      redis = {
        resources = {
          limits = {
            cpu    = "300m"
            memory = "384Mi"
          }
          requests = {
            cpu    = "150m"
            memory = "192Mi"
          }
        }
      }
      
      # ArgoCD Dex Server 설정 (CPU 부족 문제 해결을 위한 증가)
      dexServer = {
        resources = {
          limits = {
            cpu    = "300m"
            memory = "384Mi"
          }
          requests = {
            cpu    = "150m"
            memory = "192Mi"
          }
        }
      }
      
      # ArgoCD Notifications Controller 설정 (CPU 부족 문제 해결을 위한 증가)
      notificationsController = {
        resources = {
          limits = {
            cpu    = "300m"
            memory = "384Mi"
          }
          requests = {
            cpu    = "150m"
            memory = "192Mi"
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd,
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes,
    time_sleep.wait_for_nodes,
    helm_release.ingress_nginx
  ]
}
