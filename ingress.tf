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

# =============================================================================
# 네임스페이스 관리
# =============================================================================

# loventure-app 네임스페이스는 ArgoCD에서 생성됨
# Terraform에서는 Ingress 리소스만 관리

# =============================================================================
# ExternalName 서비스 정의
# 각 네임스페이스의 서비스에 접근하기 위한 ExternalName 서비스들
# =============================================================================

# ArgoCD 서버용 ExternalName 서비스 (argocd 네임스페이스)
resource "kubernetes_service" "argocd_server_external" {
  count = var.ingress_nginx_enabled ? 1 : 0

  metadata {
    name      = "argocd-server-external"
    namespace = var.argocd_namespace
  }
  
  spec {
    type          = "ExternalName"
    external_name = "argocd-server.argocd.svc.cluster.local"
  }
}

# ExternalName 서비스들은 동일 네임스페이스 내에서 불필요하므로 제거
# 직접 서비스명을 사용하여 성능 향상 및 설정 단순화

# Gateway 서비스용 ExternalName 서비스 (loventure-app 네임스페이스) - 주석처리
# resource "kubernetes_service" "gateway_external" {
#   count = var.ingress_nginx_enabled ? 1 : 0

#   metadata {
#     name      = "gateway-external"
#     namespace = "loventure-app"
#   }
  
#   spec {
#     type          = "ExternalName"
#     external_name = "loventure-prod-gateway-lb.loventure-app.svc.cluster.local"
#   }
# }

# =============================================================================
# Auth Service 전용 Ingress (api.loventure.us)
# -----------------------------------------------------------------------------
# Auth Service API 엔드포인트를 위한 전용 Ingress
resource "kubernetes_ingress_v1" "auth_service_ingress" {
  count = var.ingress_nginx_enabled ? 1 : 0

  metadata {
    name      = "auth-service-ingress"
    namespace = "loventure-app"
    annotations = {
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
    }
  }

  spec {
    # Ingress Class 설정
    ingress_class_name = "nginx"
    
    # SSL/TLS 설정
    tls {
      hosts = [var.ssl_domain_name]
      secret_name = var.ssl_enabled && var.ssl_certificate_name != "" ? data.google_compute_ssl_certificate.existing_cert[0].name : null
    }

    # Auth Service API 규칙
    rule {
      host = var.ssl_domain_name
      http {
        # OAuth2 Authorization 엔드포인트들
        path {
          path      = "/oauth2"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-auth-service"
              port {
                number = 8081
              }
            }
          }
        }
        # Auth Service API 경로들
        path {
          path      = "/api/auth"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-auth-service"
              port {
                number = 8081
              }
            }
          }
        }
        # Onboarding API 경로
        path {
          path      = "/api/onboarding"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-auth-service"
              port {
                number = 8081
              }
            }
          }
        }
        # User Management API 경로
        path {
          path      = "/api/users"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-auth-service"
              port {
                number = 8081
              }
            }
          }
        }
        # Health check 경로
        path {
          path      = "/health"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-auth-service"
              port {
                number = 8081
              }
            }
          }
        }
        # Spring Boot Actuator health check 경로
        path {
          path      = "/actuator"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-auth-service"
              port {
                number = 8081
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

# =============================================================================
# Course Service 전용 Ingress (api.loventure.us)
# -----------------------------------------------------------------------------
# Course Service API 엔드포인트를 위한 전용 Ingress
resource "kubernetes_ingress_v1" "course_service_ingress" {
  count = var.ingress_nginx_enabled ? 1 : 0

  metadata {
    name      = "course-service-ingress"
    namespace = "loventure-app"
    annotations = {
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
    }
  }

  spec {
    # Ingress Class 설정
    ingress_class_name = "nginx"
    
    # SSL/TLS 설정
    tls {
      hosts = [var.ssl_domain_name]
      secret_name = var.ssl_enabled && var.ssl_certificate_name != "" ? data.google_compute_ssl_certificate.existing_cert[0].name : null
    }

    # Course Service API 규칙
    rule {
      host = var.ssl_domain_name
      http {
        # Course API 경로들
        path {
          path      = "/api/course"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-course-service"
              port {
                number = 8083
              }
            }
          }
        }
        # Course Health check 경로
        path {
          path      = "/api/course/health"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-course-service"
              port {
                number = 8083
              }
            }
          }
        }
        # Course Actuator 경로
        path {
          path      = "/api/course/actuator"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-course-service"
              port {
                number = 8083
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

# =============================================================================
# Content Service 전용 Ingress (api.loventure.us)
# -----------------------------------------------------------------------------
# Content Service API 엔드포인트를 위한 전용 Ingress
resource "kubernetes_ingress_v1" "content_service_ingress" {
  count = var.ingress_nginx_enabled ? 1 : 0

  metadata {
    name      = "content-service-ingress"
    namespace = "loventure-app"
    annotations = {
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
    }
  }

  spec {
    # Ingress Class 설정
    ingress_class_name = "nginx"
    
    # SSL/TLS 설정
    tls {
      hosts = [var.ssl_domain_name]
      secret_name = var.ssl_enabled && var.ssl_certificate_name != "" ? data.google_compute_ssl_certificate.existing_cert[0].name : null
    }

    # Content Service API 규칙
    rule {
      host = var.ssl_domain_name
      http {
        # Diaries API 경로들
        path {
          path      = "/api/diaries"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-content-service"
              port {
                number = 8082
              }
            }
          }
        }
        # Content Health check 경로
        path {
          path      = "/api/diaries/health"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-content-service"
              port {
                number = 8082
              }
            }
          }
        }
        # Content Actuator 경로
        path {
          path      = "/api/diaries/actuator"
          path_type = "Prefix"
          backend {
            service {
              name = "loventure-prod-content-service"
              port {
                number = 8082
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

# =============================================================================
# ArgoCD 전용 Ingress (argocd 네임스페이스)
# -----------------------------------------------------------------------------
# ArgoCD 서버 접근을 위한 전용 Ingress
resource "kubernetes_ingress_v1" "argocd_ingress" {
  count = var.ingress_nginx_enabled ? 1 : 0

  metadata {
    name      = "argocd-ingress"
    namespace = var.argocd_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    # Ingress Class 설정
    ingress_class_name = "nginx"
    
    # SSL/TLS 설정
    tls {
      hosts = ["argo.loventure.us"]
      secret_name = var.ssl_enabled && var.ssl_certificate_name != "" ? data.google_compute_ssl_certificate.existing_cert[0].name : null
    }

    # ArgoCD 서버 규칙
    rule {
      host = "argo.loventure.us"
      http {
        # 모든 경로 -> ArgoCD 서버
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
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
    helm_release.ingress_nginx,
    helm_release.argocd
  ]
}

