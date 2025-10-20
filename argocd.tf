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

  values = [
    yamlencode({
      server = {
        # 개발환경용 insecure 설정
        extraArgs = ["--insecure"]
        
        # 기본 서비스 설정
        service = {
          type = "ClusterIP"
        }
        
        # Ingress 비활성화 (manifest에서 관리)
        ingress = {
          enabled = false
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

# ArgoCD Application - manifest 리포지토리 자동 관리
resource "kubernetes_manifest" "argocd_application" {
  count = var.argocd_enabled ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "argocd"
      namespace = var.argocd_namespace
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.argocd_manifest_repo
        targetRevision = var.argocd_manifest_branch
        path           = var.argocd_manifest_path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true"
        ]
      }
    }
  }

  depends_on = [
    helm_release.argocd
  ]
}
