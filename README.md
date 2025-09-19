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
└── envs/
    ├── dev.tfvars          # 개발 환경 변수
    └── prod.tfvars         # 운영 환경 변수
```

## 🚀 빠른 시작

### 1. 환경 설정
```bash
# GCP 인증
gcloud auth login
gcloud auth application-default login

# 프로젝트 설정
export GOOGLE_PROJECT_ID="your-project-id"
```

### 2. 인프라 배포
```bash
# 개발 환경 배포
terraform init
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars -auto-approve
```

### 3. 인프라 정리
```bash
# 자동 정리 (권장)
./cleanup.sh

# 또는 수동 정리
terraform destroy -var-file=envs/dev.tfvars -auto-approve
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

## 🛠️ 문제 해결

### 일반적인 문제들

#### 1. Kubernetes 네임스페이스 삭제 타임아웃
```bash
# 해결 방법
kubectl delete namespace ingress-nginx --force --grace-period=0
terraform state rm kubernetes_namespace.nginx_ingress
```

#### 2. GKE 클러스터 삭제 지연
```bash
# 해결 방법
gcloud container clusters delete pitterpetter-dev-cluster --region asia-northeast3 --project=pitterpetter --quiet
terraform state rm google_container_cluster.primary
```

#### 3. Terraform State 불일치
```bash
# 해결 방법
terraform refresh
terraform plan -var-file=envs/dev.tfvars
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

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
