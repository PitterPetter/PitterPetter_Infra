# 핵심 리소스 정의
# - GKE Cluster
# - Node Pool
# - 기타 주요 인프라 리소스

# GKE 클러스터 생성 (환경별로 Regional/Zonal 선택)
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.environment == "prod" ? var.gcp_region : var.gcp_zone
  project  = var.gcp_project_id

  # 클러스터 삭제 시 노드 풀도 함께 삭제
  remove_default_node_pool = true
  initial_node_count       = 1

  # 네트워크 설정
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  # IP 범위 설정
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "services-range"
  }

  # Private Cluster 설정 (IP 할당량 절약 + 보안 강화)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false  # 외부에서 접근 가능하도록 유지
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # 마스터 인증 네트워크 설정 (모든 IP 허용)
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "all-ips"
    }
  }

  # 클러스터 기능 설정
  addons_config {
    http_load_balancing {
      disabled = !var.cluster_http_load_balancing
    }
    horizontal_pod_autoscaling {
      disabled = !var.cluster_horizontal_pod_autoscaling
    }
    network_policy_config {
      disabled = true  # 개발환경에서는 네트워크 정책 비활성화
    }
  }

  # 네트워크 정책 설정 (개발환경에서는 주석처리 - 단순화)
  # network_policy {
  #   enabled = var.cluster_network_policy
  # }

  # Kubernetes 버전 설정
  min_master_version = var.gke_version

  # 보안 설정
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # 노드 풀 설정은 gke.tf의 google_container_node_pool에서 관리

  # 자동 업그레이드 설정 (개발환경에서는 STABLE 채널 사용)
  release_channel {
    channel = "STABLE"  # REGULAR, RAPID, STABLE 중 STABLE이 가장 안정적
  }

  # 유지보수 정책 (개발환경에서는 주석처리 - GCP가 자동으로 관리)
  # maintenance_policy {
  #   recurring_window {
  #     start_time = "2025-01-01T09:00:00Z"
  #     end_time   = "2025-01-01T17:00:00Z"
  #     recurrence = "FREQ=WEEKLY;BYDAY=SA"
  #   }
  # }

  # 노드 자동 복구 (Autopilot 또는 cluster_autoscaling이 활성화된 경우에만 사용 가능)
  # node_pool_auto_config {
  #   network_tags {
  #     tags = ["gke-node"]
  #   }
  # }


  # 삭제 보호 설정 (개발환경에서는 비활성화)
  deletion_protection = false


  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.subnet,
    google_service_account.gke_node,
    google_project_iam_member.gke_node_roles
  ]
}

# =============================================================================
# 핵심 네트워크 리소스
# =============================================================================

# VPC 생성
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  mtu                     = 1460
}

# 서브넷 생성
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_cidr
  region        = var.gcp_region
  network       = google_compute_network.vpc.id

  # GKE용 보조 IP 범위 설정
  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = var.pods_ip_cidr
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.services_ip_cidr
  }
}

# GKE 노드 풀은 gke.tf에서 관리됩니다.

# GKE 노드용 서비스 계정 생성
resource "google_service_account" "gke_node" {
  account_id   = "${var.environment}-gke-node-sa"
  display_name = "GKE Node Service Account"
  description  = "Service account for GKE nodes"
}

# 서비스 계정에 필요한 권한 부여
resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer"
  ])

  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}
