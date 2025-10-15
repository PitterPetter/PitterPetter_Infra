# Development 환경 변수 설정
# 개발 환경에 특화된 값들을 정의

# GCP 기본 설정
gcp_project_id = "pitterpetter"
environment    = "dev"
gcp_region     = "asia-northeast3"
gcp_zone       = "asia-northeast3-b"

# 네트워킹 설정
vpc_name       = "pitterpetter-dev-vpc"
subnet_name    = "pitterpetter-dev-subnet"
subnet_ip_cidr = "10.0.0.0/24"
pods_ip_cidr   = "10.1.0.0/16"
services_ip_cidr = "10.2.0.0/16"
enable_nat_gateway = true

# GKE 클러스터 설정
cluster_name   = "pitterpetter-dev-cluster"
gke_version    = "1.32.8-gke.1134000"
cluster_network_policy = true
cluster_http_load_balancing = true
cluster_horizontal_pod_autoscaling = true

# 노드 풀 설정 (개발환경 - CPU 리소스 부족 해결을 위한 업그레이드)
node_pool_name    = "pitterpetter-nodes"
node_count        = 4
min_node_count    = 4
max_node_count    = 8
node_machine_type = "e2-standard-2"
node_disk_size    = 20
node_disk_type    = "pd-standard"
node_preemptible  = false

# 보안 설정 (개발환경)
master_authorized_networks = [
  {
    cidr_block   = "0.0.0.0/0"  # 개발환경에서는 모든 IP 허용
    display_name = "dev-access"
  }
]

# Backend 설정
bucket_name     = "pit_bucket"
bucket_location = "asia-northeast3"

# SSL/TLS 설정
ssl_enabled = true
ssl_domain_name = "api.loventure.us"
ssl_certificate_name = "pitterpetter-ssl"

# Ingress 설정
ingress_nginx_enabled = true

# GMP 모니터링 설정
gmp_enabled = true
gmp_metrics_scheme = "http"
gmp_common_labels = {
  cluster     = "pitterpetter-dev-cluster"
  environment = "dev"
  project     = "pitterpetter"
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
gateway_ip_enabled = false
