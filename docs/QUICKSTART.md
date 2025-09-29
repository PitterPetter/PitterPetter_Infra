# 🚀 PitterPetter 인프라 빠른 시작 가이드

이 가이드는 새로운 팀원이 로컬에서 PitterPetter 인프라를 빠르게 설정하고 사용할 수 있도록 도와줍니다.

## ⚡ 5분 빠른 설정

### 1단계: 필수 도구 설치 (2분)
```bash
# macOS 사용자
brew install terraform gcloud kubectl helm

# Linux 사용자
# Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip && sudo mv terraform /usr/local/bin/

# Google Cloud CLI
curl https://sdk.cloud.google.com | bash && exec -l $SHELL

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 2단계: GCP 설정 (2분)
```bash
# GCP 로그인
gcloud auth login
gcloud auth application-default login

# 프로젝트 설정
gcloud config set project pitterpetter

# 필요한 API 활성화
gcloud services enable container.googleapis.com compute.googleapis.com storage.googleapis.com
```

### 3단계: 인프라 배포 (1분)
```bash
# 저장소 클론
git clone https://github.com/PitterPetter/PitterPetter_Infra.git
cd PitterPetter_Infra

# Terraform 초기화 및 배포
terraform init
terraform apply -var-file=env/dev.tfvars -auto-approve
```

## 🎯 일상적인 사용법

### 인프라 시작하기
```bash
# 클러스터 연결
gcloud container clusters get-credentials pitterpetter-dev-cluster \
    --zone asia-northeast3-b --project pitterpetter

# 상태 확인
kubectl get nodes
kubectl get namespaces
kubectl get pods -A
```

### ArgoCD 접속하기
```bash
# 방법 1: 직접 접속 (브라우저에서 보안 경고 무시)
# URL: https://34.64.212.163 (Host: argo.loventure.us)
# 사용자명: admin
# 비밀번호: dev-admin123!

# 방법 2: Port Forward 사용
kubectl port-forward svc/argocd-server -n argocd 8080:443
# 그 후 https://localhost:8080으로 접속

# 비밀번호 확인 (필요시)
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

### 다른 서비스 접속하기
```bash
# Argo Workflows: https://34.64.212.163 (Host: workflows.loventure.us)
# Argo Rollouts: https://34.64.212.163 (Host: rollouts.loventure.us)

# API 서비스들
# Auth Service: https://api.loventure.us/api/auth/*
# Course Service: https://api.loventure.us/api/course/*
# Content Service: https://api.loventure.us/api/diaries/*

# Ingress Controller 상태 확인
kubectl get svc -n ingress-nginx
kubectl get ingress -A
```

### 인프라 정리하기
```bash
# 자동 정리 (권장)
./scripts/cleanup.sh

# 또는 수동 정리
terraform destroy -var-file=env/dev.tfvars -auto-approve
```

## 🔧 자주 사용하는 명령어

### Terraform 명령어
```bash
# 변경사항 확인
terraform plan -var-file=env/dev.tfvars

# 변경사항 적용
terraform apply -var-file=env/dev.tfvars

# 상태 확인
terraform show
terraform output
```

### Kubernetes 명령어
```bash
# 모든 리소스 확인
kubectl get all --all-namespaces

# Ingress Controller 상태 확인
kubectl get pods -n ingress-nginx

# 로그 확인
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

### GCP 명령어
```bash
# 클러스터 목록
gcloud container clusters list

# 노드 목록
gcloud compute instances list

# 네트워크 확인
gcloud compute networks list
```

## 🚨 문제 해결

### 자주 발생하는 오류

#### 1. "Authentication error"
```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project pitterpetter
```

#### 2. "Provider not found"
```bash
terraform init -upgrade
```

#### 3. "ArgoCD 접속 안됨"
```bash
# Ingress Controller 상태 확인
kubectl get pods -n ingress-nginx
kubectl get ingress -n argocd

# ArgoCD 서비스 상태 확인
kubectl get svc -n argocd
kubectl get pods -n argocd

# Port Forward로 접속 시도
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

#### 4. "SSL 인증서 오류"
```bash
# 브라우저에서 "고급" → "안전하지 않은 사이트로 이동" 클릭
# 또는 Port Forward 사용
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

#### 5. "Namespace stuck in Terminating"
```bash
kubectl delete namespace argocd --force --grace-period=0
kubectl delete namespace argo --force --grace-period=0
kubectl delete namespace argo-rollouts --force --grace-period=0
kubectl delete namespace ingress-nginx --force --grace-period=0
```

#### 6. "Cluster deletion timeout"
```bash
gcloud container clusters delete pitterpetter-dev-cluster \
    --zone asia-northeast3-b --project=pitterpetter --quiet
terraform state rm google_container_cluster.primary
```

## 💡 유용한 팁

### 비용 절약
- 개발이 끝나면 `./cleanup.sh`로 리소스 정리
- 선점형 인스턴스 사용 (dev.tfvars에서 `node_preemptible = true`)

### 디버깅
- `terraform show`로 현재 상태 확인
- `kubectl describe <resource>`로 상세 정보 확인
- `gcloud logging read`로 로그 확인

### 보안
- IP 주소는 `envs/dev.tfvars`에서 `master_authorized_networks`에 추가
- 운영 환경에서는 관리자 IP만 허용

**💡 참고**: 더 자세한 내용은 [README.md](./README.md)를 확인하세요!
