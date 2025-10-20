# PitterPetter Infrastructure

**PitterPetter** 프로젝트의 GCP 기반 Kubernetes 인프라스트럭처를 Terraform으로 관리하는 저장소입니다.  
GitOps 기반의 현대적인 CI/CD 파이프라인과 마이크로서비스 아키텍처를 지원합니다.

## 🏗️ 아키텍처 개요(프로토타입)

```
┌─────────────────────────────────────────────────────────────────┐
│                        PitterPetter Infrastructure              │
├─────────────────────────────────────────────────────────────────┤
│  🌐 Internet                                                    │
│       │                                                         │
│       ▼                                                         │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              GCP Load Balancer                          │    │
│  │              (34.64.212.163)                           │    │
│  └─────────────────────────────────────────────────────────┘    │
│       │                                                         │
│       ▼                                                         │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Nginx Ingress Controller                   │    │
│  │              (ingress-nginx)                           │    │
│  └─────────────────────────────────────────────────────────┘    │
│       │                                                         │
│       ├── argocd.pitterpetter.com ──► ArgoCD (GitOps)         │
│       ├── workflows.pitterpetter.com ► Argo Workflows          │
│       ├── rollouts.pitterpetter.com ► Argo Rollouts            │
│       └── api.loventure.us ─────► Microservices                │
│           ├── /api/auth ────────► Auth Service                 │
│           ├── /api/course ──────► Course Service               │
│           └── /api/diaries ─────► Content Service              │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 프로젝트 구조

```
PitterPetter_Infra/
├── 📋 Core Infrastructure
│   ├── main.tf                    # 핵심 인프라 (VPC, 서브넷, GKE 클러스터)
│   ├── gke.tf                    # GKE 노드 풀 및 클러스터 세부 설정
│   ├── networking.tf              # 네트워크 보안 (방화벽, NAT Gateway)
│   └── providers.tf              # Terraform Provider 설정
│
├── 🌐 Ingress & SSL
│   ├── ingress.tf                # Nginx Ingress Controller + API 라우팅
│   ├── swagger_ingress.tf        # Swagger UI Ingress 설정
│   └── ssl_files/                # SSL 인증서 파일들
│
├── 🚀 GitOps & CI/CD
│   ├── argocd.tf                 # ArgoCD (GitOps 배포)
│   ├── workflows.tf              # Argo Workflows (워크플로우 오케스트레이션)
│   └── rollouts.tf               # Argo Rollouts (고급 배포 전략)
│
├── 📊 Monitoring & Observability
│   ├── gmp.tf                    # Google Managed Prometheus 설정
│   └── gmp_dashboard.tf          # GMP 대시보드 구성
│
├── ⚙️ Configuration
│   ├── variables.tf              # 모든 변수 정의 (정리됨)
│   ├── outputs.tf                # 출력값 정의 (향상됨)
│   └── backend.tf                # Terraform State 백엔드 설정
│
├── 🌍 Environment Configs
│   ├── env/
│   │   ├── dev.tfvars           # 개발환경 설정 (4-8노드, e2-standard-2)
│   │   └── prod.tfvars          # 운영환경 설정 (4-8노드, e2-standard-2)
│
├── 🛠️ Scripts & Tools
│   └── scripts/
│       └── cleanup.sh           # 인프라 정리 스크립트
│
├── 📚 Documentation
│   ├── docs/
│   │   ├── QUICKSTART.md        # 5분 빠른 시작 가이드
│   │   ├── INGRESS_GUIDE.md     # Ingress Controller 상세 가이드
│   │   └── GMP_MONITORING_GUIDE.md # GMP 모니터링 가이드
│   └── README.md               # 이 파일
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
git clone <https://github.com/PitterPetter/PitterPetter_Infra.gitl>
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

### 3. 인프라 상태 확인
```bash
# 전체 인프라 요약 정보
terraform output infrastructure_summary

# 빠른 접근 명령어들
terraform output quick_access_commands

# 특정 서비스 정보
terraform output argocd_url
terraform output ssl_domain_name
```

### 4. 클러스터 연결
```bash
# GKE 클러스터 인증 정보 가져오기
gcloud container clusters get-credentials pitterpetter-dev-cluster \
    --region asia-northeast3 \
    --project pitterpetter

# 클러스터 연결 확인
kubectl get nodes
kubectl get namespaces
```

### 5. 서비스 접속

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

### 🎯 핵심 인프라
- **Google Kubernetes Engine (GKE)**: 컨테이너 오케스트레이션
  - 클러스터: `pitterpetter-dev-cluster` (asia-northeast3-b)
  - 노드 풀: `pitterpetter-nodes` (4개 노드, e2-standard-2)
  - 자동 스케일링: 4-8개 노드
- **Virtual Private Cloud (VPC)**: 네트워크 격리 및 보안
  - VPC: `pitterpetter-dev-vpc`
  - 서브넷: `pitterpetter-dev-subnet` (10.0.0.0/24)
- **Cloud NAT**: 아웃바운드 인터넷 접근
- **Load Balancer**: 고정 IP (34.64.212.163)

### 🚀 GitOps 및 CI/CD
- **ArgoCD**: GitOps 기반 지속적 배포
  - 네임스페이스: `argocd`
  - 접속: `https://34.64.212.163` (Host: `argo.loventure.us`)
- **Argo Workflows**: 워크플로우 오케스트레이션
  - 네임스페이스: `argo`
  - 접속: `https://34.64.212.163` (Host: `workflows.loventure.us`)
- **Argo Rollouts**: 고급 배포 전략 (Blue-Green, Canary)
  - 네임스페이스: `argo-rollouts`
  - 접속: `https://34.64.212.163` (Host: `rollouts.loventure.us`)

### 🌐 API 서비스 (마이크로서비스)
- **Auth Service**: 사용자 인증 및 관리
  - 엔드포인트: `https://api.loventure.us/api/auth/*`
  - 포트: 8081
- **Course Service**: 코스 관리
  - 엔드포인트: `https://api.loventure.us/api/course/*`
  - 포트: 8083
- **Content Service**: 콘텐츠 관리 (일기 등)
  - 엔드포인트: `https://api.loventure.us/api/diaries/*`
  - 포트: 8082

### 🔒 보안 및 모니터링
- **SSL/TLS**: GCP SSL 인증서 (`pitterpetter-ssl`)
- **Nginx Ingress Controller**: 트래픽 라우팅 및 SSL 종료
- **Cloud Logging**: 중앙화된 로그 관리
- **Google Managed Prometheus (GMP)**: 완전 관리형 메트릭 수집
  - **PodMonitoring**: 8개 서비스 메트릭 수집 (애플리케이션 + ELK)
  - **Alert Rules**: 10개 알림 규칙 (핵심 서비스, 인프라, ELK)
  - **메트릭 수집 간격**: 30초
  - **공통 라벨링**: cluster, environment, project, service, type
- **Firewall Rules**: 네트워크 보안 정책

### 📊 Google Managed Prometheus (GMP) 모니터링

#### 모니터링 구성
- **PodMonitoring 리소스**: 5개 (애플리케이션 서비스)
- **대시보드**: Google Cloud Monitoring (5개 위젯)
- **메트릭 수집**: 30초 간격, HTTP 스키마
- **대상 서비스**: Gateway, Auth, Content, Course, AI

#### 대시보드 위젯
- **CPU 사용률**: `kubernetes.io/container/cpu/core_usage_time`
- **메모리 사용률**: `kubernetes.io/container/memory/used_bytes`
- **네트워크 트래픽**: 수신/송신 바이트 카운트
- **Container 재시작**: `kubernetes.io/container/restart_count`

**💡 자세한 설정**: [GMP_MONITORING_GUIDE.md](./docs/GMP_MONITORING_GUIDE.md) 참조

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

# 4. 인프라 요약 확인
terraform output infrastructure_summary
```

### 새로운 환경 변수 추가
1. `variables.tf`에 변수 정의 (기본값 제거 권장)
2. `env/dev.tfvars`에 개발환경 값 설정
3. `env/prod.tfvars`에 운영환경 값 설정
4. 코드에서 변수 사용

### 새로운 리소스 추가
1. 적절한 `.tf` 파일에 리소스 정의
2. `outputs.tf`에 필요한 출력값 추가
3. `terraform plan`으로 계획 확인
4. `terraform apply`로 적용

## 🆕 최근 업데이트 (v2.1)

### ✨ 주요 개선사항
- **환경별 설정 분리**: `env/` 디렉토리로 환경별 변수 관리
- **변수 정리**: 사용되지 않는 변수 제거 및 최적화
- **Output 향상**: 인프라 요약 정보 및 빠른 접근 명령어 추가
- **모니터링 강화**: GMP 대시보드 및 상세 모니터링 설정
- **Swagger UI**: API 문서화를 위한 Swagger UI Ingress 추가
- **인프라 안정성**: GKE 클러스터 및 네트워킹 구성 최적화
- **보안 강화**: 방화벽 규칙 및 SSL 인증서 관리 개선

### 🔧 설정 변경사항
- `variables.tf`: 불필요한 변수 제거, 코드 정리
- `outputs.tf`: `infrastructure_summary`, `quick_access_commands` 추가
- `env/`: 환경별 설정 파일 분리 (dev.tfvars, prod.tfvars)
- `gmp_dashboard.tf`: 모니터링 대시보드 추가
- `gke.tf`: GKE 클러스터 설정 최적화
- `ingress.tf`: Ingress Controller 및 라우팅 규칙 개선
- `networking.tf`: 네트워크 보안 정책 강화
- `argocd.tf`: ArgoCD 배포 설정 개선

## 🌐 서비스 접속 방법

### 🚀 ArgoCD (GitOps 배포 관리)
**접속 정보:**
- **URL**: `https://34.64.212.163` (Host: `argo.loventure.us`)
- **사용자명**: `admin`
- **비밀번호**: `dev-admin123!`

**접속 방법:**
1. **브라우저 접속** (권장):
   ```bash
   # 브라우저에서 https://34.64.212.163 접속
   # Host 헤더를 argo.loventure.us로 설정하거나
   # curl로 테스트: curl -H "Host: argo.loventure.us" -k https://34.64.212.163
   ```
   - 보안 경고가 나타나면 "고급" → "안전하지 않은 사이트로 이동" 클릭

### 🔄 Argo Workflows (워크플로우 오케스트레이션)
**접속 정보:**
- **URL**: `https://34.64.212.163` (Host: `workflows.loventure.us`)
- **Port Forward**: `kubectl port-forward svc/argo-workflows-server -n argo 2746:2746`

### 🎯 Argo Rollouts (고급 배포 전략)
**접속 정보:**
- **URL**: `https://34.64.212.163` (Host: `rollouts.loventure.us`)
- **Port Forward**: `kubectl port-forward svc/argo-rollouts-dashboard -n argo-rollouts 3100:3100`

### 🌐 API 서비스 (마이크로서비스)
**기본 URL**: `https://api.loventure.us`

**서비스별 엔드포인트:**
```bash
# Auth Service (사용자 인증)
curl -k https://api.loventure.us/api/auth/health
curl -k https://api.loventure.us/oauth2/authorize

# Course Service (코스 관리)
curl -k https://api.loventure.us/api/course/health
curl -k https://api.loventure.us/api/course/courses

# Content Service (일기 관리)
curl -k https://api.loventure.us/api/diaries/health
curl -k https://api.loventure.us/api/diaries/diaries
```

### 📚 Swagger UI (API 문서화)
**Swagger UI 접속:**
- **Auth Service**: `https://swagger-auth.loventure.us`
- **Content Service (Diaries)**: `https://swagger-diaries.loventure.us`
- **Course Service**: `https://swagger-courses.loventure.us`

**Swagger UI 상태 확인:**
```bash
# 모든 Swagger Ingress 확인
kubectl get ingress -n loventure-app | grep swagger

# 특정 Swagger UI 테스트
curl -H "Host: swagger-auth.loventure.us" -k https://34.64.212.163
```

### 🔍 시스템 상태 확인
```bash
# Ingress Controller 상태
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

# 모든 Ingress 확인
kubectl get ingress -A

# 서비스 상태 확인
kubectl get pods -n loventure-app
kubectl get svc -n loventure-app
```

### 📊 Google Managed Prometheus (GMP) 모니터링
**Cloud Monitoring URL**: `https://console.cloud.google.com/monitoring`

**GMP 상태 확인:**
```bash
# GMP Operator 상태
kubectl get pods -n gmp-system

# PodMonitoring 리소스 확인
kubectl get podmonitorings -A

# 대시보드 확인
# Google Cloud Console > Monitoring > Dashboards > "PitterPetter GMP Dashboard"

# ClusterPodMonitoring 확인
kubectl get clusterpodmonitorings
```

**메트릭 수집 확인:**
```bash
# 특정 서비스 메트릭 확인
kubectl describe podmonitoring gateway-podmonitoring

# 알림 정책 확인
kubectl describe rules <rule-name>
```

**Cloud Monitoring에서 확인할 수 있는 메트릭:**
- **애플리케이션 메트릭**: CPU, 메모리, 응답 시간, 요청 수
- **ELK 스택 메트릭**: Elasticsearch 클러스터 상태, 로그 처리량
- **인프라 메트릭**: 노드 상태, 디스크 사용량, 네트워크 트래픽

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

### 🔧 자주 발생하는 문제들

#### 1. GCP 인증 오류
```bash
# 문제: Authentication error
# 해결: GCP 인증 재설정
gcloud auth login
gcloud auth application-default login
gcloud config set project pitterpetter

# 추가 확인
gcloud auth list
gcloud config get-value project
```

#### 2. Terraform Provider 오류
```bash
# 문제: Provider not found
# 해결: Terraform 초기화
terraform init -upgrade
terraform providers

# 백엔드 문제 시
terraform init -reconfigure
```

#### 3. Kubernetes 네임스페이스 삭제 타임아웃
```bash
# 문제: Namespace stuck in Terminating state
# 해결: 강제 삭제
kubectl delete namespace argocd --force --grace-period=0
kubectl delete namespace argo --force --grace-period=0
kubectl delete namespace argo-rollouts --force --grace-period=0
kubectl delete namespace loventure-app --force --grace-period=0

# Finalizers 제거 (필요시)
kubectl patch namespace argocd -p '{"metadata":{"finalizers":null}}' --type=merge
```

#### 4. GKE 클러스터 삭제 지연
```bash
# 문제: Cluster deletion timeout
# 해결: 수동 삭제
gcloud container clusters delete pitterpetter-dev-cluster \
    --zone asia-northeast3-b \
    --project=pitterpetter --quiet

# Terraform State에서 제거
terraform state rm google_container_cluster.primary
```

#### 5. Terraform State 불일치
```bash
# 문제: State drift
# 해결: State 새로고침
terraform refresh -var-file="env/dev.tfvars"
terraform plan -var-file="env/dev.tfvars"

# 특정 리소스만 새로고침
terraform refresh -target=google_container_cluster.primary
```

#### 6. Ingress Controller 접속 불가
```bash
# 문제: 404 Not Found 또는 연결 불가
# 해결: Ingress Controller 상태 확인
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
kubectl describe pod -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# Ingress 리소스 확인
kubectl get ingress -A
kubectl describe ingress -n argocd argocd-ingress
```

#### 7. ArgoCD 접속 불가
```bash
# 문제: ArgoCD 웹 UI 접속 안됨
# 해결: ArgoCD 상태 확인
kubectl get pods -n argocd
kubectl get svc -n argocd
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# 비밀번호 확인
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

#### 8. API 서비스 502/503 오류
```bash
# 문제: API 엔드포인트 응답 없음
# 해결: 서비스 상태 확인
kubectl get pods -n loventure-app
kubectl get svc -n loventure-app
kubectl describe pod -n loventure-app -l app=auth-service

# 로그 확인
kubectl logs -n loventure-app -l app=auth-service --tail=100
```

#### 9. SSL 인증서 오류
```bash
# 문제: SSL 인증서 관련 오류
# 해결: 인증서 상태 확인
gcloud compute ssl-certificates list
kubectl get secrets -n argocd | grep tls

# Ingress TLS 설정 확인
kubectl describe ingress -n argocd argocd-ingress
```

#### 10. CPU/메모리 부족 오류
```bash
# 문제: Pod가 Pending 상태 또는 OOMKilled
# 해결: 리소스 확인 및 조정
kubectl top nodes
kubectl top pods -A
kubectl describe node

# 노드 스케일링
kubectl scale deployment --replicas=1 -n argocd argocd-server
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

## 💰 비용 최적화

### 💡 현재 비용 최적화 설정
**개발환경 (dev.tfvars):**
- **선점형 인스턴스**: `node_preemptible = true` (최대 80% 비용 절약)
- **머신 타입**: `e2-standard-2` (2 vCPU, 8GB RAM)
- **노드 수**: 4개 (자동 스케일링: 4-8개)
- **예상 월 비용**: ~$50-80 (선점형 인스턴스 사용 시)

**운영환경 (prod.tfvars):**
- **일반 인스턴스**: `node_preemptible = false` (안정성 우선)
- **머신 타입**: `e2-standard-2` (2 vCPU, 8GB RAM)
- **노드 수**: 4개 (자동 스케일링: 4-6개)
- **예상 월 비용**: ~$200-300

### 📊 비용 모니터링
```bash
# GCP 비용 확인
gcloud billing budgets list --billing-account=YOUR_BILLING_ACCOUNT

# 리소스 사용량 확인
gcloud compute instances list --filter="status:RUNNING"
gcloud container clusters list

# 특정 프로젝트 비용 확인
gcloud billing accounts list
gcloud billing budgets list --billing-account=YOUR_BILLING_ACCOUNT_ID
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
