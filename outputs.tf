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
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${google_container_cluster.primary.location} --project pitterpetter"
}

# 서비스 계정 정보
output "gke_node_service_account" {
  description = "GKE 노드 서비스 계정 이메일"
  value       = google_service_account.gke_node.email
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
  value       = var.argocd_enabled ? "https://argocd.${var.gcp_project_id}.com" : null
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
  value       = var.argoworkflows_enabled ? "https://workflows.${var.gcp_project_id}.com" : null
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
  value       = var.argo_rollouts_enabled ? "https://rollouts.${var.gcp_project_id}.com" : null
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

output "ingress_nginx_service_ip" {
  description = "Nginx Ingress Controller LoadBalancer IP"
  value       = var.ingress_nginx_enabled ? "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'" : null
}

output "ingress_nginx_status_command" {
  description = "Nginx Ingress Controller 상태 확인 명령어"
  value       = var.ingress_nginx_enabled ? "kubectl get pods -n ingress-nginx" : null
}