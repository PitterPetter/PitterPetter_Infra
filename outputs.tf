# Output 정의
# 다른 모듈이나 외부에서 참조할 수 있는 값들

# GKE 클러스터 정보
output "cluster_name" {
  description = "GKE 클러스터 이름"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "GKE 클러스터 엔드포인트"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE 클러스터 CA 인증서"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "GKE 클러스터 위치"
  value       = google_container_cluster.primary.location
}

# 네트워크 정보
output "vpc_name" {
  description = "VPC 이름"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "서브넷 이름"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_cidr" {
  description = "서브넷 CIDR"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

# 노드 풀 정보
output "node_pool_name" {
  description = "노드 풀 이름"
  value       = google_container_node_pool.primary_nodes.name
}

output "node_count" {
  description = "노드 수"
  value       = google_container_node_pool.primary_nodes.node_count
}

# kubectl 설정 명령어
output "kubectl_config_command" {
  description = "kubectl 설정을 위한 명령어"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${google_container_cluster.primary.location} --project ${var.gcp_project_id}"
}

# 서비스 계정 정보
output "gke_node_service_account" {
  description = "GKE 노드 서비스 계정 이메일"
  value       = google_service_account.gke_node.email
}

# 환경 정보
output "environment" {
  description = "현재 환경"
  value       = var.environment
}

output "gcp_project_id" {
  description = "GCP 프로젝트 ID"
  value       = var.gcp_project_id
}

output "gcp_region" {
  description = "GCP 리전"
  value       = var.gcp_region
}

# 클러스터 상세 정보
output "cluster_version" {
  description = "GKE 클러스터 버전"
  value       = google_container_cluster.primary.master_version
}

output "cluster_node_count" {
  description = "현재 노드 수"
  value       = google_container_node_pool.primary_nodes.node_count
}

output "cluster_min_node_count" {
  description = "최소 노드 수"
  value       = google_container_node_pool.primary_nodes.autoscaling[0].min_node_count
}

output "cluster_max_node_count" {
  description = "최대 노드 수"
  value       = google_container_node_pool.primary_nodes.autoscaling[0].max_node_count
}

output "cluster_machine_type" {
  description = "노드 머신 타입"
  value       = google_container_node_pool.primary_nodes.node_config[0].machine_type
}

# =============================================================================
# ArgoCD 출력값
# =============================================================================
output "argocd_enabled" {
  description = "ArgoCD 설치 여부"
  value       = var.argocd_enabled
}

output "argocd_namespace" {
  description = "ArgoCD 네임스페이스"
  value       = var.argocd_enabled ? var.argocd_namespace : null
}

output "argocd_admin_password" {
  description = "ArgoCD 관리자 비밀번호"
  value       = var.argocd_enabled ? var.argocd_admin_password : null
  sensitive   = true
}

output "argocd_url" {
  description = "ArgoCD 웹 UI URL"
  value       = var.argocd_enabled ? "https://argocd.${var.ssl_domain_name}" : null
}

# =============================================================================
# Argo Workflows 출력값
# =============================================================================
output "argoworkflows_enabled" {
  description = "Argo Workflows 설치 여부"
  value       = var.argoworkflows_enabled
}

output "argoworkflows_namespace" {
  description = "Argo Workflows 네임스페이스"
  value       = var.argoworkflows_enabled ? var.argoworkflows_namespace : null
}

output "argoworkflows_url" {
  description = "Argo Workflows 웹 UI URL"
  value       = var.argoworkflows_enabled ? "https://workflows.${var.ssl_domain_name}" : null
}

# =============================================================================
# 접속 명령어
# =============================================================================
output "argocd_port_forward_command" {
  description = "ArgoCD 로컬 포트 포워딩 명령어"
  value       = var.argocd_enabled ? "kubectl port-forward svc/argocd-server -n ${var.argocd_namespace} 8080:443" : null
}

output "argoworkflows_port_forward_command" {
  description = "Argo Workflows 로컬 포트 포워딩 명령어"
  value       = var.argoworkflows_enabled ? "kubectl port-forward svc/argo-workflows-server -n ${var.argoworkflows_namespace} 2746:2746" : null
}

# =============================================================================
# Argo Rollouts 출력값
# =============================================================================
output "argo_rollouts_enabled" {
  description = "Argo Rollouts 설치 여부"
  value       = var.argo_rollouts_enabled
}

output "argo_rollouts_namespace" {
  description = "Argo Rollouts 네임스페이스"
  value       = var.argo_rollouts_enabled ? var.argo_rollouts_namespace : null
}

output "argo_rollouts_dashboard_url" {
  description = "Argo Rollouts 대시보드 URL"
  value       = var.argo_rollouts_enabled ? "https://rollouts.${var.ssl_domain_name}" : null
}

output "argo_rollouts_port_forward_command" {
  description = "Argo Rollouts 로컬 포트 포워딩 명령어"
  value       = var.argo_rollouts_enabled ? "kubectl port-forward svc/argo-rollouts-dashboard -n ${var.argo_rollouts_namespace} 3100:3100" : null
}

# =============================================================================
# Ingress Controller 출력값
# =============================================================================
output "ingress_nginx_enabled" {
  description = "Nginx Ingress Controller 설치 여부"
  value       = var.ingress_nginx_enabled
}

output "ingress_nginx_namespace" {
  description = "Nginx Ingress Controller 네임스페이스"
  value       = var.ingress_nginx_enabled ? "ingress-nginx" : null
}

output "ingress_nginx_service_ip_command" {
  description = "Nginx Ingress Controller LoadBalancer IP 확인 명령어"
  value       = var.ingress_nginx_enabled ? "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'" : null
}

output "ingress_nginx_external_ip" {
  description = "Nginx Ingress Controller 외부 IP"
  value       = var.ingress_nginx_enabled ? "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'" : null
}

output "ingress_nginx_status_command" {
  description = "Nginx Ingress Controller 상태 확인 명령어"
  value       = var.ingress_nginx_enabled ? "kubectl get pods -n ingress-nginx" : null
}

# =============================================================================
# SSL/TLS 인증서 출력값
# =============================================================================
output "ssl_enabled" {
  description = "SSL/TLS 인증서 사용 여부"
  value       = var.ssl_enabled
}

output "ssl_domain_name" {
  description = "SSL 인증서가 적용된 도메인 이름"
  value       = var.ssl_enabled ? var.ssl_domain_name : null
}

output "ssl_certificate_name" {
  description = "Google Cloud SSL 인증서 이름"
  value       = var.ssl_enabled && var.ssl_certificate_name != "" ? data.google_compute_ssl_certificate.existing_cert[0].name : null
}

output "ssl_certificate_status_command" {
  description = "SSL 인증서 상태 확인 명령어"
  value       = var.ssl_enabled && var.ssl_certificate_name != "" ? "gcloud compute ssl-certificates describe ${data.google_compute_ssl_certificate.existing_cert[0].name} --global" : null
}


output "ssl_https_url" {
  description = "HTTPS 접속 URL"
  value       = var.ssl_enabled ? "https://${var.ssl_domain_name}" : null
}

# =============================================================================
# Google Managed Prometheus (GMP) 출력값
# =============================================================================
output "gmp_enabled" {
  description = "Google Managed Prometheus 활성화 여부"
  value       = var.gmp_enabled
}


output "gmp_common_labels" {
  description = "공통 라벨링 설정"
  value       = var.gmp_enabled ? var.gmp_common_labels : null
}

output "gmp_app_services" {
  description = "애플리케이션 서비스 메트릭 수집 설정"
  value       = var.gmp_enabled ? var.app_services : null
}

output "gmp_elk_services" {
  description = "ELK 스택 서비스 메트릭 수집 설정"
  value       = var.gmp_enabled ? var.elk_services : null
}

output "gmp_podmonitoring_count" {
  description = "생성된 PodMonitoring 리소스 수"
  value       = var.gmp_enabled ? 5 : 0
}


output "gmp_status_command" {
  description = "GMP 상태 확인 명령어"
  value       = var.gmp_enabled ? "kubectl get pods -n gmp-system" : null 
}

output "gmp_podmonitoring_list_command" {
  description = "PodMonitoring 리소스 목록 확인 명령어"
  value       = var.gmp_enabled ? "kubectl get podmonitorings -A" : null
}

output "gmp_rules_list_command" {
  description = "Rules 리소스 목록 확인 명령어"
  value       = var.gmp_enabled ? "kubectl get rules -A" : null
}

output "gmp_cloud_monitoring_url" {
  description = "Google Cloud Monitoring URL"
  value       = var.gmp_enabled ? "https://console.cloud.google.com/monitoring" : null
}

# =============================================================================
# Swagger UI 출력값
# =============================================================================
output "swagger_auth_url" {
  description = "Auth Service Swagger UI URL"
  value       = var.ingress_nginx_enabled ? "https://swagger-auth.loventure.us" : null
}

output "swagger_diaries_url" {
  description = "Content Service (Diaries) Swagger UI URL"
  value       = var.ingress_nginx_enabled ? "https://swagger-diaries.loventure.us" : null
}

output "swagger_courses_url" {
  description = "Course Service Swagger UI URL"
  value       = var.ingress_nginx_enabled ? "https://swagger-courses.loventure.us" : null
}

output "swagger_domains" {
  description = "모든 Swagger UI 도메인 목록"
  value = var.ingress_nginx_enabled ? [
    "https://swagger-auth.loventure.us",
    "https://swagger-diaries.loventure.us", 
    "https://swagger-courses.loventure.us"
  ] : []
}

output "swagger_ingress_status_command" {
  description = "Swagger Ingress 상태 확인 명령어"
  value       = var.ingress_nginx_enabled ? "kubectl get ingress -n loventure-app | grep swagger" : null
}

# =============================================================================
# 전체 인프라 요약
# =============================================================================
output "infrastructure_summary" {
  description = "전체 인프라 요약 정보"
  value = {
    environment = var.environment
    project_id = var.gcp_project_id
    region = var.gcp_region
    cluster_name = google_container_cluster.primary.name
    cluster_version = google_container_cluster.primary.master_version
    node_count = google_container_node_pool.primary_nodes.node_count
    machine_type = google_container_node_pool.primary_nodes.node_config[0].machine_type
    vpc_name = google_compute_network.vpc.name
    subnet_name = google_compute_subnetwork.subnet.name
    argocd_enabled = var.argocd_enabled
    argoworkflows_enabled = var.argoworkflows_enabled
    argo_rollouts_enabled = var.argo_rollouts_enabled
    ingress_nginx_enabled = var.ingress_nginx_enabled
    ssl_enabled = var.ssl_enabled
    ssl_domain = var.ssl_domain_name
    gmp_enabled = var.gmp_enabled
  }
}

output "quick_access_commands" {
  description = "빠른 접근을 위한 주요 명령어들"
  value = {
    kubectl_config = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${google_container_cluster.primary.location} --project ${var.gcp_project_id}"
    argocd_port_forward = var.argocd_enabled ? "kubectl port-forward svc/argocd-server -n ${var.argocd_namespace} 8080:443" : null
    argoworkflows_port_forward = var.argoworkflows_enabled ? "kubectl port-forward svc/argo-workflows-server -n ${var.argoworkflows_namespace} 2746:2746" : null
    argo_rollouts_port_forward = var.argo_rollouts_enabled ? "kubectl port-forward svc/argo-rollouts-dashboard -n ${var.argo_rollouts_namespace} 3100:3100" : null
    ingress_ip = var.ingress_nginx_enabled ? "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'" : null
    cluster_status = "kubectl get nodes"
    pod_status = "kubectl get pods -A"
  }
}