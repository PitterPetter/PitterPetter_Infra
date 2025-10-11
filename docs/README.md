# PitterPetter Infrastructure 문서

PitterPetter 프로젝트의 인프라스트럭처 관련 문서 모음입니다.

## 📚 문서 목록

### 🚀 시작하기
- **[QUICKSTART.md](./QUICKSTART.md)** - 5분 빠른 시작 가이드
- **[INGRESS_GUIDE.md](./INGRESS_GUIDE.md)** - Ingress Controller 상세 가이드

### 📊 모니터링
- **[GMP_MONITORING_GUIDE.md](./GMP_MONITORING_GUIDE.md)** - Google Managed Prometheus 모니터링 가이드

## 🏗️ 아키텍처 개요

```
┌─────────────────────────────────────────────────────────────────┐
│                    PitterPetter Infrastructure                  │
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
│                                                                 │
│  📊 모니터링 시스템                                            │
│  ├── Google Managed Prometheus (GMP)                          │
│  ├── Google Cloud Monitoring 대시보드                         │
│  └── ELK Stack (로그 관리)                                     │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 주요 구성 요소

### 인프라
- **GKE 클러스터**: 4노드 (e2-standard-2)
- **VPC 네트워크**: 전용 네트워크 및 서브넷
- **Nginx Ingress**: 로드 밸런싱 및 SSL 종료
- **ArgoCD**: GitOps 기반 배포
- **Argo Workflows**: CI/CD 워크플로우

### 모니터링
- **Google Managed Prometheus (GMP)**: 메트릭 수집
- **Google Cloud Monitoring**: 대시보드 및 알림
- **ELK Stack**: 로그 수집, 처리, 저장, 시각화

### 보안
- **SSL/TLS**: Let's Encrypt 인증서
- **방화벽**: 네트워크 보안 정책
- **IAM**: 서비스 계정 및 권한 관리

## 🚀 빠른 시작

### 1. 필수 도구 설치
```bash
# macOS
brew install terraform gcloud kubectl helm

# Linux
# 각 도구별 설치 스크립트는 QUICKSTART.md 참조
```

### 2. GCP 설정
```bash
gcloud auth login
gcloud config set project pitterpetter
gcloud services enable container.googleapis.com compute.googleapis.com
```

### 3. 인프라 배포
```bash
git clone https://github.com/PitterPetter/PitterPetter_Infra.git
cd PitterPetter_Infra
terraform init
terraform apply -var-file=env/dev.tfvars
```

### 4. 모니터링 확인
```bash
# GMP 상태 확인
kubectl get pods -n gmp-system

# 대시보드 접근
# Google Cloud Console > Monitoring > Dashboards
```

## 📖 문서 사용법

### 새로운 팀원
1. **[QUICKSTART.md](./QUICKSTART.md)** - 빠른 시작
2. **[INGRESS_GUIDE.md](./INGRESS_GUIDE.md)** - Ingress 이해
3. **[GMP_MONITORING_GUIDE.md](./GMP_MONITORING_GUIDE.md)** - 모니터링 이해

### 개발자
1. **[GMP_MONITORING_GUIDE.md](./GMP_MONITORING_GUIDE.md)** - 모니터링 설정 및 고급 사용법

### 운영팀
1. **[GMP_MONITORING_GUIDE.md](./GMP_MONITORING_GUIDE.md)** - 모니터링 관리
2. **[INGRESS_GUIDE.md](./INGRESS_GUIDE.md)** - Ingress 관리

## 🔗 관련 링크

- **메인 README**: [../README.md](../README.md)
- **Terraform 설정**: [../variables.tf](../variables.tf)
- **환경 설정**: [../env/dev.tfvars](../env/dev.tfvars)

## 📝 문서 업데이트

문서를 업데이트할 때는 다음 사항을 확인하세요:

1. **정확성**: 명령어와 설정이 현재 버전과 일치하는지 확인
2. **완전성**: 필요한 모든 단계가 포함되어 있는지 확인
3. **일관성**: 다른 문서와 일관된 형식과 내용인지 확인
4. **테스트**: 문서의 명령어를 실제로 실행해서 검증

## 🤝 기여하기

문서 개선이나 새로운 문서 추가를 원하시면:

1. 이슈 생성 또는 PR 제출
2. 문서 구조 및 내용 검토
3. 팀 리뷰 후 병합

---

**💡 팁**: 문서를 읽기 전에 [QUICKSTART.md](./QUICKSTART.md)부터 시작하는 것을 권장합니다!
