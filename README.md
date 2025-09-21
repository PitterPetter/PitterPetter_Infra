# PitterPetter Infrastructure

GCP 기반의 Kubernetes 인프라스트럭처를 Terraform으로 관리합니다.

## 📁 프로젝트 구조

```
infra-repo/
├── backend.tf              # GCS backend 정의
├── providers.tf            # 모든 provider(google, kubernetes, helm) 정의
├── variables.tf            # 모든 변수 선언
├── networking.tf           # VPC, Subnet, Firewall, NAT 등 네트워크 리소스 정의
├── main.tf                 # 핵심 리소스 정의 (GKE cluster)
├── kubernetes.tf           # Kubernetes/Helm을 이용한 애플리케이션 배포 정의
├── outputs.tf              # output 정의
├── cleanup.sh              # 인프라 정리 스크립트
├── setup.sh                # 새로운 팀원을 위한 자동 설정 스크립트
├── QUICKSTART.md           # 빠른 시작 가이드
├── README.md               # 상세 문서
└── envs/
    ├── dev.tfvars          # 개발 환경 변수
    └── prod.tfvars         # 운영 환경 변수
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

## 🚀 로컬 개발 환경 설정

### 🎯 빠른 시작 (권장)
```bash
# 1. 저장소 클론
git clone <repository-url>
cd PitterPetter_Infra

# 2. 자동 설정 스크립트 실행
./setup.sh

# 3. 인프라 배포
terraform apply -var-file=envs/dev.tfvars -auto-approve

# 4. 클러스터 연결
gcloud container clusters get-credentials pitterpetter-dev-cluster \
    --region asia-northeast3 --project pitterpetter
```

### 📖 상세 설정 (수동)

#### 1. 저장소 클론
```bash
git clone <repository-url>
cd PitterPetter_Infra
```

#### 2. 환경 변수 설정
```bash
# .env 파일 생성 (선택사항)
cat > .env << EOF
export GOOGLE_PROJECT_ID="pitterpetter"
export GOOGLE_REGION="asia-northeast3"
export GOOGLE_ZONE="asia-northeast3-a"
EOF

# 환경 변수 로드
source .env
```

#### 3. Terraform 초기화
```bash
# Terraform 초기화
terraform init

# Provider 다운로드 확인
terraform providers
```

#### 4. 개발 환경 배포
```bash
# 계획 확인
terraform plan -var-file=envs/dev.tfvars

# 배포 실행
terraform apply -var-file=envs/dev.tfvars -auto-approve
```

#### 5. Kubernetes 클러스터 연결
```bash
# GKE 클러스터 인증 정보 가져오기
gcloud container clusters get-credentials pitterpetter-dev-cluster \
    --region asia-northeast3 \
    --project pitterpetter

# 클러스터 연결 확인
kubectl get nodes
kubectl get namespaces
```

### 📚 추가 문서
- **빠른 시작**: [QUICKSTART.md](./QUICKSTART.md) - 5분 만에 시작하기
- **자동 설정**: `./setup.sh` - 모든 도구를 자동으로 설치하고 설정

## 🔧 개발 워크플로우

### 일상적인 개발 작업
```bash
# 1. 변경사항 계획 확인
terraform plan -var-file=envs/dev.tfvars

# 2. 변경사항 적용
terraform apply -var-file=envs/dev.tfvars

# 3. 상태 확인
terraform show
terraform output
```

### 새로운 환경 변수 추가
1. `variables.tf`에 변수 정의
2. `envs/dev.tfvars`에 값 설정
3. `envs/prod.tfvars`에 값 설정
4. 코드에서 변수 사용

### 새로운 리소스 추가
1. 적절한 `.tf` 파일에 리소스 정의
2. `outputs.tf`에 필요한 출력값 추가
3. `terraform plan`으로 계획 확인
4. `terraform apply`로 적용

## 🧹 인프라 정리

### 자동 정리 (권장)
```bash
# cleanup.sh 스크립트 실행
chmod +x cleanup.sh
./cleanup.sh
```

### 수동 정리
```bash
# 1. Kubernetes 리소스 정리
kubectl delete namespace ingress-nginx --force --grace-period=0

# 2. Terraform state 정리
terraform state rm kubernetes_namespace.nginx_ingress

# 3. GKE 클러스터 수동 삭제 (필요시)
gcloud container clusters delete pitterpetter-dev-cluster \
    --region asia-northeast3 \
    --project pitterpetter --quiet

# 4. Terraform destroy
terraform destroy -var-file=envs/dev.tfvars -auto-approve
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
kubectl delete namespace ingress-nginx --force --grace-period=0
terraform state rm kubernetes_namespace.nginx_ingress
```

#### 4. GKE 클러스터 삭제 지연
```bash
# 문제: Cluster deletion timeout
# 해결: 수동 삭제
gcloud container clusters delete pitterpetter-dev-cluster \
    --region asia-northeast3 \
    --project=pitterpetter --quiet
terraform state rm google_container_cluster.primary
```

#### 5. Terraform State 불일치
```bash
# 문제: State drift
# 해결: State 새로고침
terraform refresh -var-file=envs/dev.tfvars
terraform plan -var-file=envs/dev.tfvars
```

#### 6. IP 주소 충돌
```bash
# 문제: IP address already in use
# 해결: 다른 IP 대역 사용
# envs/dev.tfvars에서 subnet_ip_cidr 변경
subnet_ip_cidr = "10.1.0.0/24"  # 10.0.0.0/24 대신
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
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

## 🔧 주요 개선사항

### 1. 타임아웃 설정 개선
- **Kubernetes 리소스**: 네임스페이스 삭제 타임아웃 10분으로 증가
- **Helm 차트**: 배포 타임아웃 10분으로 증가
- **변수화**: `kubernetes_timeout`, `helm_timeout` 변수로 관리

### 2. 의존성 설정 강화
- **명시적 의존성**: `depends_on`으로 리소스 생성 순서 보장
- **서비스 계정**: GKE 클러스터 생성 전 IAM 권한 설정 완료 대기

### 3. 자동 정리 스크립트
- **cleanup.sh**: Destroy 시 발생할 수 있는 문제들을 자동으로 해결
- **Kubernetes 네임스페이스**: Finalizers 문제 해결
- **GKE 클러스터**: 수동 삭제 후 State 정리

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
- **자동 스케일링**: 1-10개 노드

### Kubernetes 리소스
- **네임스페이스**: `ingress-nginx`
- **Nginx Ingress Controller**: LoadBalancer 타입
- **Helm 차트**: ingress-nginx v4.13.2

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

### 운영환경 (prod.tfvars)
- **노드 수**: 3개
- **머신 타입**: e2-medium
- **선점형**: false (안정성)
- **NAT Gateway**: true

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
./cleanup.sh
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
        run: terraform init
      - name: Terraform Plan
        run: terraform plan -var-file=envs/dev.tfvars
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -var-file=envs/dev.tfvars -auto-approve
```

## 📚 추가 자료

### 유용한 링크
- [Terraform GCP Provider 문서](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GKE 클러스터 관리 가이드](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Helm 차트 가이드](https://helm.sh/docs/)

### 팀 내부 문서
- [개발 환경 설정 가이드](./docs/dev-setup.md)
- [배포 프로세스](./docs/deployment.md)
- [모니터링 설정](./docs/monitoring.md)

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
