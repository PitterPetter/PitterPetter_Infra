# 모든 변수 선언
# 환경별 설정값들을 변수로 정의

# =============================================================================
# GCP 기본 설정 변수
# =============================================================================
variable "gcp_project_id" {
  type        = string
  description = "리소스를 생성할 GCP 프로젝트 ID"
}

variable "gcp_region" {
  type        = string
  description = "GCP 리전"
  default     = "asia-northeast3"
}

variable "gcp_zone" {
  type        = string
  description = "GCP 존"
  default     = "asia-northeast3-a"
}

variable "environment" {
  type        = string
  description = "환경 (dev, staging, prod)"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# =============================================================================
# 네트워킹 변수
# =============================================================================
variable "vpc_name" {
  type        = string
  description = "생성할 VPC의 이름"
  default     = "pitterpetter-vpc"
}

variable "subnet_name" {
  type        = string
  description = "생성할 서브넷의 이름"
  default     = "pitterpetter-subnet"
}

variable "subnet_ip_cidr" {
  type        = string
  description = "GKE 노드들이 사용할 서브넷의 IP 대역"
  default     = "10.0.0.0/24"
}

variable "pods_ip_cidr" {
  type        = string
  description = "Pod들이 사용할 IP 대역"
  default     = "10.1.0.0/16"
}

variable "services_ip_cidr" {
  type        = string
  description = "Service들이 사용할 IP 대역"
  default     = "10.2.0.0/16"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "NAT Gateway 활성화 여부 (비용 절약을 위해 false 가능)"
  default     = true
}

# =============================================================================
# GKE 클러스터 설정 변수
# =============================================================================
variable "cluster_name" {
  type        = string
  description = "GKE 클러스터 이름"
  default     = "pitterpetter-cluster"
}

variable "gke_version" {
  type        = string
  description = "GKE 클러스터의 Kubernetes 버전. null로 두면 GCP 기본 안정 버전을 사용합니다."
  default     = null
}

variable "cluster_network_policy" {
  type        = bool
  description = "네트워크 정책 활성화"
  default     = true
}

variable "cluster_http_load_balancing" {
  type        = bool
  description = "HTTP 로드밸런싱 활성화"
  default     = true
}

variable "cluster_horizontal_pod_autoscaling" {
  type        = bool
  description = "수평 Pod 자동 스케일링 활성화"
  default     = true
}

variable "master_authorized_networks" {
  type        = list(object({
    cidr_block   = string
    display_name = string
  }))
  description = "마스터 노드 접근 허용 네트워크 (빈 배열 = 모든 IP 허용)"
  default     = []
}

# =============================================================================
# GKE 노드 풀 설정 변수
# =============================================================================
variable "node_pool_name" {
  type        = string
  description = "노드 풀 이름"
  default     = "pitterpetter-nodes"
}

variable "node_count" {
  type        = number
  description = "노드 수"
  default     = 3
}

variable "node_machine_type" {
  type        = string
  description = "노드 머신 타입"
  default     = "e2-medium"
}

variable "node_disk_size" {
  type        = number
  description = "노드 디스크 크기 (GB)"
  default     = 20
}

variable "node_disk_type" {
  type        = string
  description = "노드 디스크 타입"
  default     = "pd-standard"
}

variable "node_preemptible" {
  type        = bool
  description = "선점형 인스턴스 사용 여부 (비용 절약)"
  default     = false
}

# =============================================================================
# Backend 설정 변수
# =============================================================================
variable "bucket_name" {
  type        = string
  description = "Terraform State를 저장할 GCS 버킷 이름"
  default     = "pit_bucket"
}

variable "bucket_location" {
  type        = string
  description = "GCS 버킷 위치"
  default     = "asia-northeast3"
}

# =============================================================================
# 애플리케이션 배포 변수
# =============================================================================
variable "nginx_chart_version" {
  type        = string
  description = "배포할 Nginx Helm 차트 버전"
  default     = "4.13.2"
}

variable "nginx_namespace" {
  type        = string
  description = "Nginx Ingress Controller 네임스페이스"
  default     = "ingress-nginx"
}

variable "nginx_release_name" {
  type        = string
  description = "Nginx Helm 릴리스 이름"
  default     = "nginx-ingress"
}

variable "domain_name" {
  type        = string
  description = "도메인 이름 (선택사항)"
  default     = ""
}

# =============================================================================
# 타임아웃 설정 변수
# =============================================================================
variable "kubernetes_timeout" {
  type        = string
  description = "Kubernetes 리소스 타임아웃 설정"
  default     = "10m"
}

variable "helm_timeout" {
  type        = number
  description = "Helm 차트 배포 타임아웃 (초)"
  default     = 600
}