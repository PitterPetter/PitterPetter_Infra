# Kubernetes/Helm을 이용한 애플리케이션 배포 정의
# - Namespace
# - ConfigMap
# - Secret
# - Helm Charts

# Nginx Ingress Controller 네임스페이스 생성
resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = var.nginx_namespace
  }
  
  # 타임아웃 설정 (Destroy 시 네임스페이스 삭제 지연 문제 해결)
  timeouts {
    delete = var.kubernetes_timeout  # 10분으로 증가
  }
}

# Nginx Ingress Controller Helm Chart 배포
resource "helm_release" "nginx_ingress" {
  name       = var.nginx_release_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_chart_version
  namespace  = kubernetes_namespace.nginx_ingress.metadata[0].name
  wait       = true
  timeout    = var.helm_timeout  # 10분으로 증가

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = ""  # GCP가 자동으로 외부 IP 할당
  }

  depends_on = [google_container_cluster.primary]
}