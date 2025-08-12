# TPB — AWS · Terraform 기반 WordPress HTTPS 인프라

## 📌 인프라 구성 흐름

### 1. 전체 아키텍처
![아키텍처 다이어그램](docs/images/infra-architecture.png)  
CloudFront → ALB(HTTPS) → EC2(ASG) → RDS / Route 53·ACM 연결 구조

---

### 2. TLS 적용 구조
![TLS/ACM Architecture](docs/images/tls-acm-architecture.png)  
CloudFront(us-east-1)와 ALB(ap-northeast-2)에서 단계별 HTTPS 처리

---

### 3. VPC & 서브넷 구성
![VPC & Subnets](docs/images/vpc-subnets.png)  
퍼블릭·프라이빗 서브넷을 AZ별로 분리 배치

---

### 4. ALB 리스너 & 인증서
![ALB Listeners](docs/images/alb-listeners.png)  
:80 → :443 리다이렉트, :443 → Target Group Forward (ACM 적용)

---

### 5. Auto Scaling & WordPress 설치
![ASG Launch Template](docs/images/asg-launch-template.png)  
UserData로 EC2 부팅 시 Nginx·PHP-FPM·WordPress 자동 설치

---

### 6. RDS & 보안 그룹
![RDS Security](docs/images/rds-security.png)  
Private Subnet에 배치, EC2 SG 참조만 허용

---

### 7. Route 53 레코드
![Route 53 Records](docs/images/route53-records.png)  
root/www → CloudFront, origin → ALB (A-ALIAS)

---

### 8. CloudFront 배포
![CloudFront Distribution](docs/images/cloudfront-distribution.png)  
Origin HTTPS-Only, 캐싱 정책 적용

---

### 9. HTTPS 동작 확인
![HTTPS Redirect](docs/images/wp-https-redirect.png)  
HTTP 접속 시 HTTPS로 강제 전환

---

### 10. CloudFront 응답 헤더
![CF Response Headers](docs/images/cf-response-headers.png)  
HTTP/2, X-Cache 확인

---

### 11. Terraform 배포 로그
![Terraform Apply](docs/images/terraform-apply.png)  
`terraform apply` 성공 후 리소스 생성 요약
