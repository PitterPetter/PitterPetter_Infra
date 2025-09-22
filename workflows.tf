# Argo Workflows 배포 및 설정
# - Argo Workflows 네임스페이스
# - Argo Workflows Helm 차트 배포
# - 워크플로우 설정

# Argo Workflows 네임스페이스 생성
resource "kubernetes_namespace" "argoworkflows" {
  count = var.argoworkflows_enabled ? 1 : 0
  
  metadata {
    name = var.argoworkflows_namespace
    labels = {
      "app.kubernetes.io/name"     = "argo-workflows"
      "app.kubernetes.io/instance" = "argo-workflows"
    }
  }

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes,
    time_sleep.wait_for_nodes
  ]
}

# Argo Workflows Helm 차트 배포
resource "helm_release" "argoworkflows" {
  count = var.argoworkflows_enabled ? 1 : 0

  name       = "argo-workflows"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  version    = var.argoworkflows_chart_version
  namespace  = var.argoworkflows_namespace

  # Argo Workflows values 설정
  values = [
    yamlencode({
      # Argo Workflows Server 설정
      server = {
        enabled = true
        service = {
          type = "ClusterIP"
        }
        
        # Ingress 설정 (Nginx Ingress Controller 사용)
        ingress = {
          enabled = true
          annotations = {
            "kubernetes.io/ingress.class" = "nginx"
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
          }
          ingressClassName = "nginx"
          hosts = ["workflows.${var.gcp_project_id}.com"]
          tls = [{
            secretName = "argo-workflows-server-tls"
            hosts = ["workflows.${var.gcp_project_id}.com"]
          }]
        }
        
        # 리소스 제한
        resources = {
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      }
      
      # Argo Workflows Controller 설정
      controller = {
        resources = {
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
        
        # 워크플로우 실행을 위한 설정
        workflowRestrictions = {
          templateReferencing = "Strict"
        }
      }
      
      # Argo Workflows Executor 설정
      executor = {
        resources = {
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
        }
      }
      
      # 워크플로우 아카이브 설정
      archive = {
        enabled = true
        resources = {
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argoworkflows,
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes,
    time_sleep.wait_for_nodes,
    helm_release.ingress_nginx,
    helm_release.argocd
  ]
}
