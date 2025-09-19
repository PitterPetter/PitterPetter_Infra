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
