# Argo Rollouts 배포 및 설정
# - Argo Rollouts 네임스페이스
# - Argo Rollouts Helm 차트 배포
# - 배포 전략 관리 설정

# Argo Rollouts 네임스페이스 생성
resource "kubernetes_namespace" "argo_rollouts" {
  count = var.argo_rollouts_enabled ? 1 : 0
  
  metadata {
    name = var.argo_rollouts_namespace
    labels = {
      "app.kubernetes.io/name"     = "argo-rollouts"
      "app.kubernetes.io/instance" = "argo-rollouts"
    }
  }

  depends_on = [google_container_cluster.primary]
}

# Argo Rollouts Helm 차트 배포
resource "helm_release" "argo_rollouts" {
  count = var.argo_rollouts_enabled ? 1 : 0

  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  version    = var.argo_rollouts_chart_version
  namespace  = var.argo_rollouts_namespace

  # Argo Rollouts values 설정
  values = [
    yamlencode({
      # Argo Rollouts Controller 설정
      controller = {
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
        
        # 메트릭 서버 설정
        metrics = {
          enabled = true
          service = {
            type = "ClusterIP"
            port = 8090
          }
        }
        
        # 로그 레벨 설정
        logLevel = "info"
        
        # 웹훅 설정
        webhook = {
          enabled = true
          port    = 9443
        }
      }
      
      # Argo Rollouts Dashboard 설정
      dashboard = {
        enabled = true
        service = {
          type = "ClusterIP"
          port = 3100
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
          hosts = ["rollouts.${var.gcp_project_id}.com"]
          tls = [{
            secretName = "argo-rollouts-dashboard-tls"
            hosts = ["rollouts.${var.gcp_project_id}.com"]
          }]
        }
        
        # 리소스 제한 (CPU 부족 문제 해결을 위한 증가)
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
      
      # RBAC 설정
      rbac = {
        enabled = true
        create  = true
      }
      
      # Service Account 설정
      serviceAccount = {
        create = true
        name   = "argo-rollouts"
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argo_rollouts,
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes,
    helm_release.ingress_nginx
  ]
}
