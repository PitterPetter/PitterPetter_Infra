# Google Managed Prometheus (GMP) 설정
# - PodMonitoring 리소스 (메트릭 수집)
# - Rules 리소스 (알림 규칙)

# =============================================================================
# 애플리케이션 서비스 PodMonitoring
# =============================================================================

# Gateway Service PodMonitoring
resource "kubernetes_manifest" "gateway_podmonitoring" {
  count = var.gmp_enabled ? 1 : 0
  
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "gateway-podmonitoring"
      namespace = "gmp-public"
      labels    = merge(var.gmp_common_labels, {
        service = "gateway"
        type    = "application"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          app = "gateway"
        }
      }
      endpoints = [{
        port     = var.app_services.gateway.port
        path     = var.app_services.gateway.prometheus_enabled ? "/actuator/prometheus" : var.app_services.gateway.path
        scheme   = var.gmp_metrics_scheme
        interval = var.app_services.gateway.interval
      }]
    }
  }
}

# Auth Service PodMonitoring
resource "kubernetes_manifest" "auth_podmonitoring" {
  count = var.gmp_enabled ? 1 : 0
  
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "auth-podmonitoring"
      namespace = "gmp-public"
      labels    = merge(var.gmp_common_labels, {
        service = "auth"
        type    = "application"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          app = "auth-service"
        }
      }
      endpoints = [{
        port     = var.app_services.auth.port
        path     = var.app_services.auth.prometheus_enabled ? "/actuator/prometheus" : var.app_services.auth.path
        scheme   = var.gmp_metrics_scheme
        interval = var.app_services.auth.interval
      }]
    }
  }
}

# Content Service PodMonitoring
resource "kubernetes_manifest" "content_podmonitoring" {
  count = var.gmp_enabled ? 1 : 0
  
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "content-podmonitoring"
      namespace = "gmp-public"
      labels    = merge(var.gmp_common_labels, {
        service = "content"
        type    = "application"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          app = "content-service"
        }
      }
      endpoints = [{
        port     = var.app_services.content.port
        path     = var.app_services.content.prometheus_enabled ? "/actuator/prometheus" : var.app_services.content.path
        scheme   = var.gmp_metrics_scheme
        interval = var.app_services.content.interval
      }]
    }
  }
}

# Course Service PodMonitoring
resource "kubernetes_manifest" "course_podmonitoring" {
  count = var.gmp_enabled ? 1 : 0
  
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "course-podmonitoring"
      namespace = "gmp-public"
      labels    = merge(var.gmp_common_labels, {
        service = "course"
        type    = "application"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          app = "course-service"
        }
      }
      endpoints = [{
        port     = var.app_services.course.port
        path     = var.app_services.course.prometheus_enabled ? "/actuator/prometheus" : var.app_services.course.path
        scheme   = var.gmp_metrics_scheme
        interval = var.app_services.course.interval
      }]
    }
  }
}

# AI Service PodMonitoring
resource "kubernetes_manifest" "ai_podmonitoring" {
  count = var.gmp_enabled ? 1 : 0
  
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "ai-podmonitoring"
      namespace = "gmp-public"
      labels    = merge(var.gmp_common_labels, {
        service = "ai"
        type    = "application"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          app = "ai-service"
        }
      }
      endpoints = [{
        port     = var.app_services.ai.port
        path     = var.app_services.ai.prometheus_enabled ? "/metrics" : var.app_services.ai.path
        scheme   = var.gmp_metrics_scheme
        interval = var.app_services.ai.interval
      }]
    }
  }
}

# =============================================================================
# ELK 스택 PodMonitoring
# =============================================================================

# Elasticsearch PodMonitoring (비활성화)
resource "kubernetes_manifest" "elasticsearch_podmonitoring" {
  count = 0  # 비활성화 - 핵심 서비스만 모니터링
  
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "elasticsearch-podmonitoring"
      namespace = "gmp-public"
      labels    = merge(var.gmp_common_labels, {
        service = "elasticsearch"
        type    = "elk"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          app = "loventure-elk-master"
        }
      }
      endpoints = [{
        port     = var.elk_services.elasticsearch.port
        path     = var.elk_services.elasticsearch.path
        scheme   = var.gmp_metrics_scheme
        interval = var.elk_services.elasticsearch.interval
      }]
    }
  }
}

# Kibana PodMonitoring (비활성화)
resource "kubernetes_manifest" "kibana_podmonitoring" {
  count = 0  # 비활성화 - 핵심 서비스만 모니터링
  
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "kibana-podmonitoring"
      namespace = "gmp-public"
      labels    = merge(var.gmp_common_labels, {
        service = "kibana"
        type    = "elk"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          app = "kibana"
        }
      }
      endpoints = [{
        port     = var.elk_services.kibana.port
        path     = var.elk_services.kibana.path
        scheme   = var.gmp_metrics_scheme
        interval = var.elk_services.kibana.interval
      }]
    }
  }
}

# Logstash PodMonitoring (비활성화)
resource "kubernetes_manifest" "logstash_podmonitoring" {
  count = 0  # 비활성화 - 핵심 서비스만 모니터링
  
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "logstash-podmonitoring"
      namespace = "gmp-public"
      labels    = merge(var.gmp_common_labels, {
        service = "logstash"
        type    = "elk"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          app = "logstash-logstash"
        }
      }
      endpoints = [{
        port     = var.elk_services.logstash.port
        path     = var.elk_services.logstash.path
        scheme   = var.gmp_metrics_scheme
        interval = var.elk_services.logstash.interval
      }]
    }
  }
}

# Filebeat PodMonitoring (비활성화)
resource "kubernetes_manifest" "filebeat_podmonitoring" {
  count = 0  # 비활성화 - 핵심 서비스만 모니터링
  
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "filebeat-podmonitoring"
      namespace = "gmp-public"
      labels    = merge(var.gmp_common_labels, {
        service = "filebeat"
        type    = "elk"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          app = "filebeat-filebeat"
        }
      }
      endpoints = [{
        port     = var.elk_services.filebeat.port
        path     = var.elk_services.filebeat.path
        scheme   = var.gmp_metrics_scheme
        interval = var.elk_services.filebeat.interval
      }]
    }
  }
}