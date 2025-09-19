# 모든 provider 정의
# - Google Cloud Provider
# - Kubernetes Provider  
# - Helm Provider



# Terraform이 요구하는 Provider의 버전 등을 설정합니다.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
}

# Google Cloud Provider의 기본 설정을 정의합니다.
provider "google" {
  project = "pitterpetter"
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# Provider가 GKE 클러스터 정보를 참조할 수 있도록 데이터 소스를 정의합니다.
data "google_client_config" "default" {}

# Kubernetes Provider 설정 (클러스터 생성 후에 설정됨)
provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

# Helm Provider 설정 (클러스터 생성 후에 설정됨)
provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}