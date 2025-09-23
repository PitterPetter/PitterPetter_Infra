# 🌐 Ingress Controller 가이드

PitterPetter 인프라에서 사용하는 Nginx Ingress Controller에 대한 상세 가이드입니다.

## 📋 개요

현재 인프라는 **Nginx Ingress Controller**를 사용하여 외부에서 Kubernetes 서비스에 접근할 수 있도록 합니다.

### 아키텍처
```
외부 사용자 → LoadBalancer (34.64.212.163) → Nginx Ingress Controller → 도메인별 라우팅
                                                                    ├── argocd.pitterpetter.com → ArgoCD
                                                                    ├── workflows.pitterpetter.com → Argo Workflows
                                                                    └── rollouts.pitterpetter.com → Argo Rollouts
```

## 🔧 현재 설정

### LoadBalancer 정보
- **외부 IP**: `34.64.212.163`
- **포트**: 80 (HTTP), 443 (HTTPS)
- **타입**: External LoadBalancer

### 배포된 서비스들
| 서비스 | 도메인 | 네임스페이스 | 포트 |
|--------|--------|-------------|------|
| ArgoCD | `argocd.pitterpetter.com` | `argocd` | 80, 443 |
| Argo Workflows | `workflows.pitterpetter.com` | `argo` | 80, 443 |
| Argo Rollouts | `rollouts.pitterpetter.com` | `argo-rollouts` | 80, 443 |

## 🚀 접속 방법

### 1. 브라우저 접속 (권장)
```bash
# ArgoCD
https://34.64.212.163
# Host 헤더: argocd.pitterpetter.com

# Argo Workflows  
https://34.64.212.163
# Host 헤더: workflows.pitterpetter.com

# Argo Rollouts
https://34.64.212.163
# Host 헤더: rollouts.pitterpetter.com
```

**주의사항**: SSL 인증서가 자체 서명되어 있어 브라우저에서 보안 경고가 나타납니다. "고급" → "안전하지 않은 사이트로 이동"을 클릭하여 진행하세요.

### 2. Port Forward 사용
```bash
# ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
# 접속: https://localhost:8080

# Argo Workflows
kubectl port-forward svc/argo-workflows-server -n argo 2746:2746
# 접속: http://localhost:2746

# Argo Rollouts
kubectl port-forward svc/argo-rollouts-dashboard -n argo-rollouts 3100:3100
# 접속: http://localhost:3100
```

### 3. curl로 테스트
```bash
# ArgoCD 테스트
curl -H "Host: argocd.pitterpetter.com" -k https://34.64.212.163

# Argo Workflows 테스트
curl -H "Host: workflows.pitterpetter.com" -k https://34.64.212.163

# Argo Rollouts 테스트
curl -H "Host: rollouts.pitterpetter.com" -k https://34.64.212.163
```

## 🔍 상태 확인

### Ingress Controller 상태
```bash
# Pod 상태 확인
kubectl get pods -n ingress-nginx

# 서비스 상태 확인
kubectl get svc -n ingress-nginx

# 로그 확인
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

### Ingress 리소스 확인
```bash
# 모든 Ingress 확인
kubectl get ingress -A

# 특정 Ingress 상세 정보
kubectl describe ingress argocd-server -n argocd
```

### 서비스 상태 확인
```bash
# ArgoCD 상태
kubectl get pods -n argocd
kubectl get svc -n argocd

# Argo Workflows 상태
kubectl get pods -n argo
kubectl get svc -n argo

# Argo Rollouts 상태
kubectl get pods -n argo-rollouts
kubectl get svc -n argo-rollouts
```

## 🛠️ 관리 명령어

### Ingress Controller 재시작
```bash
kubectl rollout restart deployment/ingress-nginx-controller -n ingress-nginx
```

### Ingress 설정 업데이트
```bash
# Ingress 리소스 수정 후 적용
kubectl apply -f your-ingress.yaml

# 또는 Helm으로 업데이트
helm upgrade ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
```

### 로그 모니터링
```bash
# 실시간 로그 확인
kubectl logs -f -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# 특정 시간대 로그
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --since=1h
```

## 🚨 문제 해결

### 1. 404 Not Found 오류
```bash
# Ingress Controller가 실행 중인지 확인
kubectl get pods -n ingress-nginx

# Ingress 리소스가 올바르게 설정되었는지 확인
kubectl get ingress -A
kubectl describe ingress <ingress-name> -n <namespace>
```

### 2. SSL 인증서 오류
```bash
# TLS 시크릿 확인
kubectl get secrets -n argocd | grep tls

# 인증서 상세 정보 확인
kubectl describe secret argocd-server-tls -n argocd
```

### 3. 서비스 연결 오류
```bash
# 백엔드 서비스가 실행 중인지 확인
kubectl get pods -n <namespace>
kubectl get svc -n <namespace>

# 서비스 엔드포인트 확인
kubectl get endpoints -n <namespace>
```

### 4. LoadBalancer IP 변경
```bash
# 현재 IP 확인
kubectl get svc -n ingress-nginx ingress-nginx-controller

# IP가 변경된 경우 DNS 업데이트 필요
# 또는 새로운 IP로 접속
```

## 📝 새로운 서비스 추가하기

### 1. Ingress 리소스 생성
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: your-service-ingress
  namespace: your-namespace
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  rules:
  - host: your-service.pitterpetter.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: your-service
            port:
              number: 80
  tls:
  - hosts:
    - your-service.pitterpetter.com
    secretName: your-service-tls
```

### 2. 적용
```bash
kubectl apply -f your-ingress.yaml
```

### 3. 확인
```bash
kubectl get ingress -A
curl -H "Host: your-service.pitterpetter.com" -k https://34.64.212.163
```

## 🔒 보안 고려사항

### 현재 설정
- **마스터 접근**: 모든 IP 허용 (`0.0.0.0/0`)
- **SSL 인증서**: 자체 서명된 인증서 사용
- **방화벽**: HTTP(80), HTTPS(443) 포트만 개방

### 운영 환경 권장사항
1. **마스터 접근 제한**: 특정 IP만 허용
2. **SSL 인증서**: Let's Encrypt 또는 상용 인증서 사용
3. **도메인 설정**: 실제 도메인과 DNS 레코드 설정
4. **모니터링**: 접근 로그 및 보안 이벤트 모니터링

## 📚 참고 자료

- [Nginx Ingress Controller 공식 문서](https://kubernetes.github.io/ingress-nginx/)
- [Kubernetes Ingress 가이드](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [GKE Ingress 가이드](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress)
