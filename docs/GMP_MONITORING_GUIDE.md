# Google Managed Prometheus (GMP) 모니터링 가이드

## 📋 개요

PitterPetter 프로젝트에서 Google Managed Prometheus (GMP)를 사용하여 애플리케이션과 인프라를 모니터링합니다.

## 🏗️ 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                    Google Managed Prometheus (GMP)              │
├─────────────────────────────────────────────────────────────────┤
│  📊 GMP Operator                                               │
│  ├── PodMonitoring (5개) - 애플리케이션 서비스 모니터링         │
│  └── ClusterNodeMonitoring - 노드 레벨 모니터링               │
│                                                                 │
│  📈 Google Cloud Monitoring                                   │
│  ├── 대시보드 (5개 위젯)                                       │
│  └── 메트릭 수집 (30초 간격)                                   │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 설정 구성

### PodMonitoring 리소스 (5개)

**애플리케이션 서비스 모니터링:**
- **Gateway** (포트 8080): `/actuator/health` 또는 `/actuator/prometheus`
- **Auth Service** (포트 8081): `/actuator/health` 또는 `/actuator/prometheus`
- **Content Service** (포트 8082): `/actuator/health` 또는 `/actuator/prometheus`
- **Course Service** (포트 8083): `/actuator/health` 또는 `/actuator/prometheus`
- **AI Service** (포트 8000): `/health` 또는 `/metrics`

### 메트릭 수집 설정

```hcl
# variables.tf
variable "gmp_enabled" {
  type        = bool
  description = "Google Managed Prometheus 활성화 여부"
  default     = true
}

variable "gmp_metrics_interval" {
  type        = string
  description = "메트릭 수집 간격"
  default     = "30s"
}
```

## 📊 대시보드 구성

### Google Cloud Monitoring 대시보드

**대시보드 이름**: "PitterPetter GMP Dashboard"

**위젯 구성 (5개):**

1. **CPU 사용률 (Container)**
   - 메트릭: `kubernetes.io/container/cpu/core_usage_time`
   - 리소스: `k8s_container`

2. **메모리 사용률 (Container)**
   - 메트릭: `kubernetes.io/container/memory/used_bytes`
   - 리소스: `k8s_container`

3. **네트워크 수신 (Pod)**
   - 메트릭: `kubernetes.io/pod/network/received_bytes_count`
   - 리소스: `k8s_pod`

4. **네트워크 송신 (Pod)**
   - 메트릭: `kubernetes.io/pod/network/sent_bytes_count`
   - 리소스: `k8s_pod`

5. **Container 재시작 횟수**
   - 메트릭: `kubernetes.io/container/restart_count`
   - 리소스: `k8s_container`

## 🚀 배포 방법

### Terraform으로 배포

```bash
# 개발환경 배포
terraform apply -var-file=env/dev.tfvars

# 대시보드만 재배포
terraform apply -var-file=env/dev.tfvars -target=google_monitoring_dashboard.gmp_dashboard
```

### 수동 확인

```bash
# GMP 상태 확인
kubectl get pods -n gmp-system

# PodMonitoring 리소스 확인
kubectl get podmonitorings -A

# 대시보드 확인
# Google Cloud Console > Monitoring > Dashboards
```

## 🔍 모니터링 확인

### 1. 대시보드 접근

1. **Google Cloud Console** 접속
2. **Monitoring** > **Dashboards** 이동
3. **"PitterPetter GMP Dashboard"** 선택

### 2. 메트릭 확인

```bash
# 특정 서비스 메트릭 확인
kubectl get podmonitoring gateway-podmonitoring -n gmp-public -o yaml

# GMP Collector 로그 확인
kubectl logs -n gmp-system -l app=gmp-collector
```

## ⚙️ 고급 설정

### Prometheus 메트릭 활성화

Spring Boot 서비스에서 Prometheus 메트릭을 활성화하려면:

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
```

```xml
<!-- pom.xml -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

## 🐛 문제 해결

### 자주 발생하는 문제

1. **"Invalid argument X" 오류 발생시:**
   - 메트릭 타입이 올바른지 확인
   - 리소스 타입이 올바른지 확인 (`k8s_container` vs `k8s_pod`)
   - 클러스터 이름이 정확한지 확인

2. **"0 time series" 표시시:**
   - PodMonitoring이 정상적으로 생성되었는지 확인
   - 대상 Pod가 실행 중인지 확인
   - 메트릭 엔드포인트가 응답하는지 확인

3. **메트릭 수집이 안됨:**
   - GMP Operator가 정상 실행 중인지 확인
   - 네트워크 정책이 메트릭 수집을 차단하지 않는지 확인

### 로그 확인

```bash
# GMP Operator 로그
kubectl logs -n gmp-system -l app=gmp-operator

# GMP Collector 로그
kubectl logs -n gmp-system -l app=gmp-collector

# 특정 PodMonitoring 로그
kubectl describe podmonitoring gateway-podmonitoring -n gmp-public
```

## 📚 참고 자료

- [Google Managed Prometheus 문서](https://cloud.google.com/stackdriver/docs/managed-prometheus)
- [Kubernetes Monitoring 가이드](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)
- [Spring Boot Actuator 문서](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Micrometer Prometheus 레지스트리](https://micrometer.io/docs/registry/prometheus)