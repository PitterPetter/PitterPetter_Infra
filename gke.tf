# GKE 노드 풀 및 클러스터 세부 설정
# - Node Pool
# - 클러스터 세부 설정
# 
# 핵심 GKE 클러스터는 main.tf에서 관리됩니다.

# GKE 노드 풀 생성 (1개 노드 풀에 여러 노드)
resource "google_container_node_pool" "primary_nodes" {
  name       = var.node_pool_name
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  project    = var.gcp_project_id
  node_count = var.node_count  # dev: 2개, prod: 3개

  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size
    disk_type    = var.node_disk_type
    # 환경별 preemptible 설정: 개발환경은 true, 운영환경은 false
    preemptible  = var.node_preemptible != null ? var.node_preemptible : (var.environment == "dev" ? true : false)

    # GKE 노드 태그
    tags = ["gke-node"]

    # 서비스 계정 설정
    service_account = google_service_account.gke_node.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # 메타데이터 설정
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # 이미지 설정
    image_type = "COS_CONTAINERD"
  }

  # 자동 스케일링 설정 (환경별로 다른 설정)
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # 업그레이드 설정
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # 업그레이드 전략 설정 (SURGE 전략으로 변경 - 더 빠름)
  upgrade_settings {
    strategy = "SURGE"
  }

  depends_on = [google_container_cluster.primary]
}

# 노드 풀 준비 완료 대기 (최소 2분)
resource "time_sleep" "wait_for_nodes" {
  depends_on = [google_container_node_pool.primary_nodes]
  
  create_duration = "2m"
}
