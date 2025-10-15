# Production 환경 변수 설정
# 운영 환경에 특화된 값들을 정의

# GCP 기본 설정
gcp_project_id = "pitterpetter-2"
environment    = "prod"
gcp_region     = "asia-northeast3"
gcp_zone       = "asia-northeast3-b"

# 네트워킹 설정
vpc_name       = "pitterpetter-prod-vpc"
subnet_name    = "pitterpetter-prod-subnet"
subnet_ip_cidr = "10.0.0.0/24"
pods_ip_cidr   = "10.1.0.0/16"
services_ip_cidr = "10.2.0.0/16"
enable_nat_gateway = true

# GKE 클러스터 설정
cluster_name   = "pitterpetter-prod-cluster"
gke_version    = "1.32.8-gke.1170000"  # 안정적인 버전 고정
cluster_network_policy = true
cluster_http_load_balancing = true
cluster_horizontal_pod_autoscaling = true

# 노드 풀 설정
node_pool_name    = "pitterpetter-nodes"
node_count        = 4
min_node_count    = 4
max_node_count    = 8
node_machine_type = "e2-standard-2"
node_disk_size    = 20
node_disk_type    = "pd-standard"
node_preemptible  = false  # 안정성을 위해 일반 인스턴스

# 보안 설정 (운영환경)
master_authorized_networks = [
  {
    cidr_block   = "0.0.0.0/0"  # 실제로는 관리자 IP로 제한
    display_name = "admin-access"
  }
]

# Backend 설정
bucket_name     = "pit_bucket_prod"
bucket_location = "asia-northeast3"

# SSL/TLS 설정
ssl_enabled = true
ssl_domain_name = "loventure.us"
ssl_certificate_name = "pitterpetter-ssl-prod"

# Ingress 설정
ingress_nginx_enabled = true

# GMP 모니터링 설정
gmp_enabled = true
gmp_metrics_scheme = "http"
gmp_common_labels = {
  cluster     = "pitterpetter-prod-cluster"
  environment = "prod"
  project     = "pitterpetter-2"
}

# ArgoCD 설정
argocd_enabled = true
argocd_namespace = "argocd"
argocd_chart_version = "5.51.6"
argocd_admin_password = "admin123!"

# Argo Workflows 설정
argoworkflows_enabled = true
argoworkflows_namespace = "argo"
argoworkflows_chart_version = "0.40.0"

# Argo Rollouts 설정
argo_rollouts_enabled = true
argo_rollouts_namespace = "argo-rollouts"
argo_rollouts_chart_version = "2.31.1"

# Ingress Controller 설정
ingress_nginx_chart_version = "4.8.3"

# 게이트웨이 설정
gateway_ip_enabled = true  # 운영환경에서는 고정 IP 사용
