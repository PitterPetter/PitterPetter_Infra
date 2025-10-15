# 네트워크 보안 및 고급 설정
# - Firewall Rules
# - NAT Gateway
# - Cloud Router
# 
# 핵심 네트워크 리소스(VPC, 서브넷)는 main.tf에서 관리됩니다.

# Cloud Router 생성 (NAT Gateway용)
resource "google_compute_router" "router" {
  count   = var.enable_nat_gateway ? 1 : 0
  name    = "${var.vpc_name}-router"
  region  = var.gcp_region
  network = google_compute_network.vpc.id
}

# 고정 외부 IP 할당
resource "google_compute_address" "nat_ip" {
  count  = var.enable_nat_gateway ? 1 : 0
  name   = "${var.vpc_name}-nat-ip"
  region = var.gcp_region
}

# NAT Gateway 생성
resource "google_compute_router_nat" "nat" {
  count                              = var.enable_nat_gateway ? 1 : 0
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.router[0].name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip[0].self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# 방화벽 규칙 - SSH 접근 허용
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.vpc_name}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# 방화벽 규칙 - HTTP/HTTPS 허용
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.vpc_name}-allow-http-https"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
}

# 방화벽 규칙 - GKE 노드 간 통신 허용
resource "google_compute_firewall" "allow_gke_nodes" {
  name    = "${var.vpc_name}-allow-gke-nodes"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_tags = ["gke-node"]
  target_tags = ["gke-node"]
}

# 방화벽 규칙 - Debezium → Kafka 통신 허용
resource "google_compute_firewall" "allow_debezium_to_kafka" {
  name    = "allow-debezium-to-kafka"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["9092"]
  }

  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["kafka"]
}

# 방화벽 규칙 - Debezium → PostgreSQL 통신 허용
resource "google_compute_firewall" "allow_debezium_to_postgres" {
  name    = "allow-debezium-to-postgres"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["31234"]
  }

  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["gke-node"]
}

# 방화벽 규칙 - Kafka UI 접근 허용
resource "google_compute_firewall" "allow_kafka_ui" {
  name    = "kafka-ui"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8081"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["kafka"]
}

# 방화벽 규칙 - 내부 네트워크 전체 통신 허용
resource "google_compute_firewall" "allow_internal_all" {
  name    = "${var.vpc_name}-allow-internal-all"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24"]
}