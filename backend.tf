# GCS backend 정의
# Terraform state를 Google Cloud Storage에 저장

terraform {
  backend "gcs" {
    bucket = "pit_bucket"
    prefix = "terraform/state"
  }
}
