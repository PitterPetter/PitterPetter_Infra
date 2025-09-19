# 네트워크 리소스 정의
# - VPC
# - Subnet
# - Firewall Rules
# - NAT Gateway
# - Cloud Router

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

# Cloud Router 생성 (NAT Gateway용)
resource "google_compute_router" "router" {
  count   = var.enable_nat_gateway ? 1 : 0
  name    = "${var.vpc_name}-router"
  region  = var.gcp_region
  network = google_compute_network.vpc.id
}

# NAT Gateway 생성
resource "google_compute_router_nat" "nat" {
  count                              = var.enable_nat_gateway ? 1 : 0
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.router[0].name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
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