# PitterPetter Infrastructure

GCP 기반의 Kubernetes 인프라스트럭처를 Terraform으로 관리하는 저장소입니다.

## 📁 프로젝트 구조

```
PitterPetter_Infra/
├── main.tf                    # 핵심 인프라 (VPC, 서브넷, GKE 클러스터, 기본 서비스 계정)
├── networking.tf              # 네트워크 보안 (방화벽, NAT Gateway, Cloud Router)
├── gke.tf                    # GKE 노드 풀 및 클러스터 세부 설정
├── ingress.tf                # Nginx Ingress Controller 배포 및 설정
├── argocd.tf                 # ArgoCD 배포 및 설정
├── workflows.tf              # Argo Workflows 배포 및 설정
├── rollouts.tf               # Argo Rollouts 배포 및 설정
├── providers.tf              # Provider 설정
├── variables.tf              # 변수 정의
├── outputs.tf                # 출력값 정의
├── backend.tf                # 백엔드 설정
├── env/                      # 환경별 설정
│   ├── dev.tfvars           # 개발환경 변수
│   └── prod.tfvars          # 운영환경 변수
├── scripts/                  # 유틸리티 스크립트
│   └── cleanup.sh           # 정리 스크립트
├── docs/                    # 문서
│   ├── QUICKSTART.md        # 빠른 시작 가이드
│   └── INGRESS_GUIDE.md     # Ingress Controller 가이드
└── README.md               # 이 파일
```

## 🛠️ 사전 요구사항

### 필수 도구 설치
```bash
# 1. Terraform 설치 (v1.5+)
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# 2. Google Cloud CLI 설치
# macOS
brew install google-cloud-sdk

# Linux
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# 3. kubectl 설치
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 4. Helm 설치
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### GCP 프로젝트 설정
```bash
# 1. GCP 프로젝트 생성 및 활성화
gcloud projects create pitterpetter --name="PitterPetter"
gcloud config set project pitterpetter

# 2. 필요한 API 활성화
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable iam.googleapis.com

# 3. GCP 인증
gcloud auth login
gcloud auth application-default login

# 4. 서비스 계정 생성 (선택사항)
gcloud iam service-accounts create terraform-sa \
    --display-name="Terraform Service Account" \
    --description="Service account for Terraform operations"
```

## 🚀 빠른 시작

### 1. 저장소 클론
```bash
git clone <repository-url>
cd PitterPetter_Infra
```

### 2. 인프라 배포

#### 개발환경 배포
```bash
terraform init
terraform plan -var-file="env/dev.tfvars"
terraform apply -var-file="env/dev.tfvars"
```

#### 운영환경 배포
```bash
terraform init
terraform plan -var-file="env/prod.tfvars"
terraform apply -var-file="env/prod.tfvars"
```

### 3. 클러스터 연결
```bash
# GKE 클러스터 인증 정보 가져오기
gcloud container clusters get-credentials pitterpetter-dev-cluster \
    --region asia-northeast3 \
    --project pitterpetter

# 클러스터 연결 확인
kubectl get nodes
kubectl get namespaces
```

### 4. 서비스 접속

#### ArgoCD 접속
```bash
# 포트 포워딩
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 웹 브라우저에서 접속
# https://localhost:8080
# 사용자명: admin
# 비밀번호: dev-admin123! (개발환경)
```

#### Argo Workflows 접속
```bash
# 포트 포워딩
kubectl port-forward svc/argo-workflows-server -n argo 2746:2746

# 웹 브라우저에서 접속
# https://localhost:2746
```

#### Argo Rollouts 접속
```bash
# 포트 포워딩
kubectl port-forward svc/argo-rollouts-dashboard -n argo-rollouts 3100:3100

# 웹 브라우저에서 접속
# https://localhost:3100
```

## 🏗️ 인프라 구성 요소

### 핵심 인프라
- **Google Kubernetes Engine (GKE)**: 컨테이너 오케스트레이션
- **Virtual Private Cloud (VPC)**: 네트워크 격리 및 보안
- **Cloud NAT**: 아웃바운드 인터넷 접근

### GitOps 및 배포
- **ArgoCD**: GitOps 기반 지속적 배포
- **Argo Workflows**: 워크플로우 오케스트레이션
- **Argo Rollouts**: 고급 배포 전략 (Blue-Green, Canary)

### 모니터링 및 보안
- **Cloud Logging**: 중앙화된 로그 관리
- **Cloud Monitoring**: 메트릭 수집 및 알림
- **Firewall Rules**: 네트워크 보안 정책

## 🔧 개발 워크플로우

### 일상적인 개발 작업
```bash
# 1. 변경사항 계획 확인
terraform plan -var-file="env/dev.tfvars"

# 2. 변경사항 적용
terraform apply -var-file="env/dev.tfvars"

# 3. 상태 확인
terraform show
terraform output
```

### 새로운 환경 변수 추가
1. `variables.tf`에 변수 정의
2. `env/dev.tfvars`에 값 설정
3. `env/prod.tfvars`에 값 설정
4. 코드에서 변수 사용

### 새로운 리소스 추가
1. 적절한 `.tf` 파일에 리소스 정의
2. `outputs.tf`에 필요한 출력값 추가
3. `terraform plan`으로 계획 확인
4. `terraform apply`로 적용

## 🌐 서비스 접속 방법

### ArgoCD (GitOps)
**URL**: `https://34.64.212.163` (Host: `argocd.pitterpetter.com`)
- **사용자명**: `admin`
- **비밀번호**: `UIA1qqIsXzKkearS` (또는 `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d`)

**접속 방법:**
1. **브라우저 접속**: `https://34.64.212.163`
   - 보안 경고가 나타나면 "고급" → "안전하지 않은 사이트로 이동" 클릭
2. **Port Forward**: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
   - 그 후 `https://localhost:8080`으로 접속

### Argo Workflows (워크플로우 관리)
**URL**: `https://34.64.212.163` (Host: `workflows.pitterpetter.com`)

### Argo Rollouts (배포 관리)
**URL**: `https://34.64.212.163` (Host: `rollouts.pitterpetter.com`)

### Ingress Controller 상태 확인
```bash
# Ingress Controller 상태
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

# 모든 Ingress 확인
kubectl get ingress -A
```

## 🧹 인프라 정리

### 자동 정리 (권장)
```bash
# cleanup.sh 스크립트 실행
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh
```

### 수동 정리
```bash
# 1. Kubernetes 리소스 정리
kubectl delete namespace argocd --force --grace-period=0
kubectl delete namespace argo --force --grace-period=0
kubectl delete namespace argo-rollouts --force --grace-period=0

# 2. Terraform destroy
terraform destroy -var-file="env/dev.tfvars" -auto-approve
```

## 🚨 문제 해결 가이드

### 자주 발생하는 문제들

#### 1. GCP 인증 오류
```bash
# 문제: Authentication error
# 해결: GCP 인증 재설정
gcloud auth login
gcloud auth application-default login
gcloud config set project pitterpetter
```

#### 2. Terraform Provider 오류
```bash
# 문제: Provider not found
# 해결: Terraform 초기화
terraform init -upgrade
terraform providers
```

#### 3. Kubernetes 네임스페이스 삭제 타임아웃
```bash
# 문제: Namespace stuck in Terminating state
# 해결: 강제 삭제
kubectl delete namespace argocd --force --grace-period=0
kubectl delete namespace argo --force --grace-period=0
kubectl delete namespace argo-rollouts --force --grace-period=0
```

#### 4. GKE 클러스터 삭제 지연
```bash
# 문제: Cluster deletion timeout
# 해결: 수동 삭제
gcloud container clusters delete pitterpetter-dev-cluster \
    --region asia-northeast3 \
    --project=pitterpetter --quiet
```

#### 5. Terraform State 불일치
```bash
# 문제: State drift
# 해결: State 새로고침
terraform refresh -var-file="env/dev.tfvars"
terraform plan -var-file="env/dev.tfvars"
```

### 디버깅 명령어
```bash
# Terraform 상태 확인
terraform show
terraform state list
terraform output

# GCP 리소스 확인
gcloud compute instances list
gcloud container clusters list
gcloud compute networks list

# Kubernetes 리소스 확인
kubectl get all --all-namespaces
kubectl describe nodes
kubectl logs -n argocd -l app.kubernetes.io/name=argocd
```

## 📊 리소스 구성

### 네트워킹
- **VPC**: `pitterpetter-dev-vpc`
- **서브넷**: `pitterpetter-dev-subnet` (10.0.0.0/24)
- **방화벽**: SSH, HTTP/HTTPS, GKE 노드 통신
- **NAT Gateway**: `pitterpetter-dev-vpc-nat`

### GKE 클러스터
- **클러스터**: `pitterpetter-dev-cluster`
- **노드 풀**: `pitterpetter-nodes` (2개 노드)
- **머신 타입**: e2-small (개발환경)
- **자동 스케일링**: 2-5개 노드

### Kubernetes 리소스
- **ArgoCD**: `argocd` 네임스페이스
- **Argo Workflows**: `argo` 네임스페이스
- **Argo Rollouts**: `argo-rollouts` 네임스페이스

## 🔒 보안 설정

### 마스터 인증 네트워크
- **개발환경**: 현재 IP만 허용
- **운영환경**: 관리자 IP만 허용

### 서비스 계정
- **GKE 노드**: `dev-gke-node-sa`
- **권한**: 로깅, 모니터링, 스토리지 접근

## 📝 환경별 설정

### 개발환경 (dev.tfvars)
- **노드 수**: 2개
- **머신 타입**: e2-small
- **선점형**: true (비용 절약)
- **NAT Gateway**: true
- **ArgoCD 비밀번호**: dev-admin123!

### 운영환경 (prod.tfvars)
- **노드 수**: 3개
- **머신 타입**: e2-medium
- **선점형**: false (안정성)
- **NAT Gateway**: true
- **ArgoCD 비밀번호**: prod-admin-2024!

## 💰 비용 최적화

### 개발환경 비용 절약 팁
```bash
# 1. 선점형 인스턴스 사용 (dev.tfvars)
node_preemptible = true

# 2. 작은 머신 타입 사용
node_machine_type = "e2-small"

# 3. 최소 노드 수 사용
node_count = 2

# 4. 사용하지 않을 때 클러스터 삭제
./scripts/cleanup.sh
```

### 비용 모니터링
```bash
# GCP 비용 확인
gcloud billing budgets list --billing-account=YOUR_BILLING_ACCOUNT

# 리소스 사용량 확인
gcloud compute instances list --filter="status:RUNNING"
gcloud container clusters list
```

## 🚀 CI/CD 통합

### GitHub Actions 예시
```yaml
name: Deploy Infrastructure
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Setup GCP
        uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GCP_SA_KEY }}
      - name: Terraform Init
        run: cd terraform && terraform init
      - name: Terraform Plan
        run: cd terraform && terraform plan -var-file="environments/dev.tfvars"
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: cd terraform && terraform apply -var-file="environments/dev.tfvars" -auto-approve
```

## 📚 추가 자료

### 프로젝트 문서
- **[빠른 시작 가이드](./docs/QUICKSTART.md)**: 새로운 팀원을 위한 5분 설정 가이드
- **[Ingress Controller 가이드](./docs/INGRESS_GUIDE.md)**: Nginx Ingress Controller 상세 가이드

### 유용한 링크
- [Terraform GCP Provider 문서](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GKE 클러스터 관리 가이드](https://cloud.google.com/kubernetes-engine/docs)
- [ArgoCD 공식 문서](https://argo-cd.readthedocs.io/)
- [Argo Workflows 문서](https://argoproj.github.io/argo-workflows/)
- [Argo Rollouts 문서](https://argoproj.github.io/argo-rollouts/)
- [Helm 차트 가이드](https://helm.sh/docs/)

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 지원

문제가 발생하거나 질문이 있으시면 이슈를 생성해 주세요.