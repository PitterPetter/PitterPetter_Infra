variable "gcp_project_id" {
  type        = string
  description = "리소스를 생성할 GCP 프로젝트 ID"
}

variable "gcp_region" {
  type        = string
  description = "GCP 리전"
}

variable "gcp_zone" {
  type        = string
  description = "GCP 존"
}

variable "environment" {
  type        = string
  description = "환경 (dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "vpc_name" {
  type        = string
  description = "생성할 VPC의 이름"
}

variable "subnet_name" {
  type        = string
  description = "생성할 서브넷의 이름"
}

variable "subnet_ip_cidr" {
  type        = string
  description = "GKE 노드들이 사용할 서브넷의 IP 대역"
}

variable "pods_ip_cidr" {
  type        = string
  description = "Pod들이 사용할 IP 대역"
}

variable "services_ip_cidr" {
  type        = string
  description = "Service들이 사용할 IP 대역"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "NAT Gateway 활성화 여부"
}

variable "cluster_name" {
  type        = string
  description = "GKE 클러스터 이름"
}

variable "gke_version" {
  type        = string
  description = "GKE 클러스터의 Kubernetes 버전. null로 두면 GCP 기본 안정 버전을 사용합니다."
  default     = null
}

variable "cluster_network_policy" {
  type        = bool
  description = "네트워크 정책 활성화"
}

variable "cluster_http_load_balancing" {
  type        = bool
  description = "HTTP 로드밸런싱 활성화"
}

variable "cluster_horizontal_pod_autoscaling" {
  type        = bool
  description = "수평 Pod 자동 스케일링 활성화"
}

variable "master_authorized_networks" {
  type        = list(object({
    cidr_block   = string
    display_name = string
  }))
  description = "마스터 노드 접근 허용 네트워크 (빈 배열 = 모든 IP 허용)"
}

variable "node_pool_name" {
  type        = string
  description = "노드 풀 이름"
}

variable "node_count" {
  type        = number
  description = "초기 노드 수 (자동 스케일링으로 변경됨)"
}

variable "min_node_count" {
  type        = number
  description = "최소 노드 수 (자동 스케일링)"
}

variable "max_node_count" {
  type        = number
  description = "최대 노드 수 (자동 스케일링)"
}

variable "node_machine_type" {
  type        = string
  description = "노드 머신 타입"
}

variable "node_disk_size" {
  type        = number
  description = "노드 디스크 크기 (GB)"
}

variable "node_disk_type" {
  type        = string
  description = "노드 디스크 타입"
}

variable "node_preemptible" {
  type        = bool
  description = "선점형 인스턴스 사용 여부 (개발환경: true, 운영환경: false)"
}

variable "bucket_name" {
  type        = string
  description = "Terraform State를 저장할 GCS 버킷 이름"
}

variable "bucket_location" {
  type        = string
  description = "GCS 버킷 위치"
}


variable "argocd_enabled" {
  type        = bool
  description = "ArgoCD 설치 여부"
}

variable "argocd_namespace" {
  type        = string
  description = "ArgoCD 네임스페이스"
}

variable "argocd_chart_version" {
  type        = string
  description = "ArgoCD Helm 차트 버전"
}

variable "argocd_admin_password" {
  type        = string
  description = "ArgoCD 관리자 비밀번호"
  sensitive   = true
}

# ArgoCD Manifest 관련 변수들
variable "argocd_manifest_repo" {
  type        = string
  description = "ArgoCD가 관리할 manifest 리포지토리 URL"
}

variable "argocd_manifest_path" {
  type        = string
  description = "ArgoCD가 관리할 manifest 경로"
}

variable "argocd_manifest_branch" {
  type        = string
  description = "ArgoCD가 관리할 manifest 브랜치 (환경별로 다름)"
}

variable "argoworkflows_enabled" {
  type        = bool
  description = "Argo Workflows 설치 여부"
}

variable "argoworkflows_namespace" {
  type        = string
  description = "Argo Workflows 네임스페이스"
}

variable "argoworkflows_chart_version" {
  type        = string
  description = "Argo Workflows Helm 차트 버전"
}

variable "ingress_nginx_enabled" {
  type        = bool
  description = "Nginx Ingress Controller 설치 여부"
}

variable "ingress_nginx_chart_version" {
  type        = string
  description = "Nginx Ingress Controller Helm 차트 버전"
}

variable "argo_rollouts_enabled" {
  type        = bool
  description = "Argo Rollouts 설치 여부"
}

variable "argo_rollouts_namespace" {
  type        = string
  description = "Argo Rollouts 네임스페이스"
}

variable "argo_rollouts_chart_version" {
  type        = string
  description = "Argo Rollouts Helm 차트 버전"
}

variable "ssl_enabled" {
  type        = bool
  description = "SSL/TLS 인증서 사용 여부"
}

variable "ssl_domain_name" {
  type        = string
  description = "SSL 인증서를 적용할 도메인 이름"
}

variable "ssl_certificate_name" {
  type        = string
  description = "GCP에서 직접 업로드한 SSL 인증서 이름"
}

variable "gateway_ip_enabled" {
  type        = bool
  description = "게이트웨이 서비스 전용 고정 IP 사용 여부"
  default     = true
}

variable "gmp_enabled" {
  type        = bool
  description = "Google Managed Prometheus 활성화 여부"
}


variable "gmp_metrics_scheme" {
  type        = string
  description = "메트릭 수집 스키마"
}

variable "gmp_common_labels" {
  type = map(string)
  description = "공통 라벨링 설정"
}

variable "app_services" {
  type = map(object({
    port     = number
    path     = string
    interval = optional(string, "30s")
    prometheus_enabled = optional(bool, false)
  }))
  description = "애플리케이션 서비스 메트릭 수집 설정"
  default = {
    gateway = {
      port     = 8080
      path     = "/actuator/health"
      interval = "30s"
      prometheus_enabled = false
    }
    auth = {
      port     = 8081
      path     = "/actuator/health"
      interval = "30s"
      prometheus_enabled = false
    }
    content = {
      port     = 8082
      path     = "/actuator/health"
      interval = "30s"
      prometheus_enabled = false
    }
    course = {
      port     = 8083
      path     = "/actuator/health"
      interval = "30s"
      prometheus_enabled = false
    }
    ai = {
      port     = 8000
      path     = "/health"
      interval = "30s"
      prometheus_enabled = false
    }
  }
}

variable "elk_services" {
  type = map(object({
    port     = number
    path     = string
    interval = optional(string, "30s")
  }))
  description = "ELK 스택 서비스 메트릭 수집 설정"
  default = {
    elasticsearch = {
      port     = 9200
      path     = "/_prometheus/metrics"
      interval = "30s"
    }
    kibana = {
      port     = 5601
      path     = "/api/status"
      interval = "30s"
    }
    logstash = {
      port     = 9600
      path     = "/_node/stats"
      interval = "30s"
    }
    filebeat = {
      port     = 5066
      path     = "/stats"
      interval = "30s"
    }
  }
}

