# =============================================================================
# Swagger UI 전용 Ingress 설정
# -----------------------------------------------------------------------------
# 각 서비스별로 별도의 호스트명을 사용하여 Swagger UI에 접근

# =============================================================================
# Auth Service Swagger UI Ingress
# -----------------------------------------------------------------------------
# swagger-auth.loventure.us -> Auth Service
resource "kubernetes_ingress_v1" "swagger_auth_ingress" {
  count = var.ingress_nginx_enabled ? 1 : 0

  metadata {
    name      = "swagger-auth-ingress"
    namespace = "loventure-app"
    labels = {
      "app.kubernetes.io/name"     = "swagger-ui"
      "app.kubernetes.io/instance" = "swagger-auth"
      "app.kubernetes.io/component" = "ingress"
    }
    annotations = {
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-origin" = "http://localhost:5173, https://api.loventure.us, https://loventure.us, https://swagger-auth.loventure.us, https://swagger-diaries.loventure.us, https://swagger-courses.loventure.us"
      "nginx.ingress.kubernetes.io/cors-allow-methods" = "GET, POST, PUT, DELETE, OPTIONS"
      "nginx.ingress.kubernetes.io/cors-allow-headers" = "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization"
      "nginx.ingress.kubernetes.io/cors-allow-credentials" = "true"
      "nginx.ingress.kubernetes.io/proxy-buffer-size" = "16k"
      "nginx.ingress.kubernetes.io/proxy-buffers-number" = "8"
    }
  }

  spec {
    # Ingress Class 설정
    ingress_class_name = "nginx"
    
    # SSL/TLS 설정
    tls {
      hosts = ["swagger-auth.loventure.us"]
      secret_name = var.ssl_enabled && var.ssl_certificate_name != "" ? data.google_compute_ssl_certificate.existing_cert[0].name : null
    }

    # Auth Service Swagger UI 규칙
    rule {
      host = "swagger-auth.loventure.us"
      http {
        # 모든 경로를 Auth Service로 라우팅
        path {
          path      = "/"
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
# Content Service Swagger UI Ingress
# -----------------------------------------------------------------------------
# swagger-diaries.loventure.us -> Content Service
resource "kubernetes_ingress_v1" "swagger_diaries_ingress" {
  count = var.ingress_nginx_enabled ? 1 : 0

  metadata {
    name      = "swagger-diaries-ingress"
    namespace = "loventure-app"
    labels = {
      "app.kubernetes.io/name"     = "swagger-ui"
      "app.kubernetes.io/instance" = "swagger-diaries"
      "app.kubernetes.io/component" = "ingress"
    }
    annotations = {
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-origin" = "http://localhost:5173, https://api.loventure.us, https://loventure.us, https://swagger-auth.loventure.us, https://swagger-diaries.loventure.us, https://swagger-courses.loventure.us"
      "nginx.ingress.kubernetes.io/cors-allow-methods" = "GET, POST, PUT, DELETE, OPTIONS"
      "nginx.ingress.kubernetes.io/cors-allow-headers" = "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization"
      "nginx.ingress.kubernetes.io/cors-allow-credentials" = "true"
      "nginx.ingress.kubernetes.io/proxy-buffer-size" = "16k"
      "nginx.ingress.kubernetes.io/proxy-buffers-number" = "8"
    }
  }

  spec {
    # Ingress Class 설정
    ingress_class_name = "nginx"
    
    # SSL/TLS 설정
    tls {
      hosts = ["swagger-diaries.loventure.us"]
      secret_name = var.ssl_enabled && var.ssl_certificate_name != "" ? data.google_compute_ssl_certificate.existing_cert[0].name : null
    }

    # Content Service Swagger UI 규칙
    rule {
      host = "swagger-diaries.loventure.us"
      http {
        # 모든 경로를 Content Service로 라우팅
        path {
          path      = "/"
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
# Course Service Swagger UI Ingress
# -----------------------------------------------------------------------------
# swagger-courses.loventure.us -> Course Service
resource "kubernetes_ingress_v1" "swagger_courses_ingress" {
  count = var.ingress_nginx_enabled ? 1 : 0

  metadata {
    name      = "swagger-courses-ingress"
    namespace = "loventure-app"
    labels = {
      "app.kubernetes.io/name"     = "swagger-ui"
      "app.kubernetes.io/instance" = "swagger-courses"
      "app.kubernetes.io/component" = "ingress"
    }
    annotations = {
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-origin" = "http://localhost:5173, https://api.loventure.us, https://loventure.us, https://swagger-auth.loventure.us, https://swagger-diaries.loventure.us, https://swagger-courses.loventure.us"
      "nginx.ingress.kubernetes.io/cors-allow-methods" = "GET, POST, PUT, DELETE, OPTIONS"
      "nginx.ingress.kubernetes.io/cors-allow-headers" = "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization"
      "nginx.ingress.kubernetes.io/cors-allow-credentials" = "true"
      "nginx.ingress.kubernetes.io/proxy-buffer-size" = "16k"
      "nginx.ingress.kubernetes.io/proxy-buffers-number" = "8"
    }
  }

  spec {
    # Ingress Class 설정
    ingress_class_name = "nginx"
    
    # SSL/TLS 설정
    tls {
      hosts = ["swagger-courses.loventure.us"]
      secret_name = var.ssl_enabled && var.ssl_certificate_name != "" ? data.google_compute_ssl_certificate.existing_cert[0].name : null
    }

    # Course Service Swagger UI 규칙
    rule {
      host = "swagger-courses.loventure.us"
      http {
        # 모든 경로를 Course Service로 라우팅
        path {
          path      = "/"
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
