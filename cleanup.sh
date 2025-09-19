#!/bin/bash
# PitterPetter Infrastructure Cleanup Script
# 이 스크립트는 Terraform destroy 시 발생할 수 있는 문제들을 해결합니다.

set -e

echo "🧹 PitterPetter Infrastructure Cleanup 시작..."

# 1. Kubernetes 네임스페이스 강제 삭제 (Finalizers 문제 해결)
echo "📦 Kubernetes 네임스페이스 정리 중..."
kubectl delete namespace ingress-nginx --force --grace-period=0 2>/dev/null || echo "네임스페이스가 이미 삭제되었거나 존재하지 않습니다."

# 2. Terraform State에서 Kubernetes 리소스 제거
echo "🗂️ Terraform State 정리 중..."
terraform state rm kubernetes_namespace.nginx_ingress 2>/dev/null || echo "Kubernetes 네임스페이스가 State에 없습니다."

# 3. GKE 클러스터 상태 확인 및 수동 삭제 (필요시)
echo "☸️ GKE 클러스터 상태 확인 중..."
CLUSTER_STATUS=$(gcloud container clusters list --project=pitterpetter --filter="name:pitterpetter-dev-cluster" --format="value(status)" 2>/dev/null || echo "")

if [ "$CLUSTER_STATUS" = "STOPPING" ] || [ "$CLUSTER_STATUS" = "RUNNING" ]; then
    echo "⚠️ GKE 클러스터가 아직 삭제 중이거나 실행 중입니다. 수동으로 삭제합니다..."
    gcloud container clusters delete pitterpetter-dev-cluster --region asia-northeast3 --project=pitterpetter --quiet
    terraform state rm google_container_cluster.primary 2>/dev/null || echo "GKE 클러스터가 State에 없습니다."
fi

# 4. Terraform Destroy 실행
echo "💥 Terraform Destroy 실행 중..."
terraform destroy -var-file=envs/dev.tfvars -auto-approve

echo "✅ 정리 완료!"
