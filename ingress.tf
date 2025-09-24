# Nginx Ingress Controller 배포
# Private Cluster에서 외부 접근을 위한 Ingress Controller

# =============================================================================
# SSL/TLS 인증서 설정 (GCP에서 직접 업로드한 인증서 참조)
# =============================================================================

# GCP에서 직접 업로드한 SSL 인증서 참조 (Compute Engine SSL 인증서)
data "google_compute_ssl_certificate" "existing_cert" {
  count = var.ssl_enabled && var.ssl_certificate_name != "" ? 1 : 0
  name  = var.ssl_certificate_name
}

# Nginx Ingress Controller 네임스페이스
resource "kubernetes_namespace" "ingress_nginx" {
  count = var.ingress_nginx_enabled ? 1 : 0
  
  metadata {
    name = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"     = "ingress-nginx"
      "app.kubernetes.io/instance" = "ingress-nginx"
    }
  }
}

# 고정 외부 IP 할당 (LoadBalancer용)
resource "google_compute_address" "ingress_ip" {
  count  = var.ingress_nginx_enabled ? 1 : 0
  name   = "${var.vpc_name}-ingress-ip"
  region = var.gcp_region
}

# Nginx Ingress Controller Helm 차트 배포
resource "helm_release" "ingress_nginx" {
  count = var.ingress_nginx_enabled ? 1 : 0

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_chart_version
  namespace  = kubernetes_namespace.ingress_nginx[0].metadata[0].name

  values = [
    yamlencode({
      controller = {
        # 개발환경 최적화를 위한 단일 복제본 설정
        replicaCount = 1
        
        # 안티어피니티 설정 (다른 노드에 배치)
        affinity = {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [
              {
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchExpressions = [
                      {
                        key = "app.kubernetes.io/name"
                        operator = "In"
                        values = ["ingress-nginx"]
                      }
                    ]
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }
            ]
          }
        }
        
        service = {
          type = "LoadBalancer"
          loadBalancerIP = google_compute_address.ingress_ip[0].address
          annotations = merge(
            {
              "cloud.google.com/load-balancer-type" = "External"
            },
            var.ssl_enabled && var.ssl_certificate_name != "" ? {
              "cloud.google.com/load-balancer-ssl-certificates" = data.google_compute_ssl_certificate.existing_cert[0].name
              "cloud.google.com/load-balancer-backend-protocol" = "HTTP"
            } : {}
          )
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
        
        # Private Cluster에서 외부 접근 허용
        config = {
          "use-proxy-protocol" = "false"
          "ssl-protocols" = "TLSv1.2 TLSv1.3"
        }
        
        # Ingress 설정
        ingressClassResource = {
          name = "nginx"
          enabled = true
          default = true
        }
        
        # 헬스체크 설정
        livenessProbe = {
          httpGet = {
            path = "/healthz"
            port = 10254
          }
          initialDelaySeconds = 10
          periodSeconds = 10
        }
        
        readinessProbe = {
          httpGet = {
            path = "/healthz"
            port = 10254
          }
          initialDelaySeconds = 10
          periodSeconds = 10
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.ingress_nginx,
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes,
    time_sleep.wait_for_nodes
  ]
}

# API 서비스용 Ingress (표준 헬스체크 경로 사용)
resource "kubernetes_ingress_v1" "api_ingress" {
  count = var.ingress_nginx_enabled ? 1 : 0

  metadata {
    name      = "api-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      host = var.ssl_domain_name
      http {
        path {
          path      = "/health"
          path_type = "Prefix"
          backend {
            service {
              name = "api-service"
              port {
                number = 80
              }
            }
          }
        }
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "api-service"
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
    helm_release.ingress_nginx
  ]
}
