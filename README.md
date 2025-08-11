# 🌐 AWS WordPress HTTPS 인프라 자동화 (Terraform)

![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-21759B?style=flat&logo=wordpress&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat&logo=nginx&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat&logo=mariadb&logoColor=white)

---

## 📌 프로젝트 개요
이 프로젝트는 Terraform을 활용해 AWS에 **HTTPS 지원 WordPress 인프라**를 자동으로 구축합니다.  
**CloudFront → ALB → EC2(WordPress) → RDS(MariaDB)** 구성으로 고가용성과 보안성을 확보했으며,  
도메인과 SSL 인증서 발급까지 전부 한 번의 `terraform apply`로 가능합니다.

---

## 🏗 아키텍처
![architecture](docs/architecture.png)

> **요약**  
> - **CloudFront**: 글로벌 CDN + HTTPS 강제  
> - **ALB**: 로드 밸런싱 + HTTPS 종료  
> - **EC2**: Nginx + PHP-FPM + WordPress 설치 자동화  
> - **RDS**: 외부 접근 차단, EC2만 접속 가능  
> - **Route 53 + ACM**: 도메인 연결 및 인증서 관리  

---

## ✨ 주요 특징
- **완전 자동화**: 인프라 생성, WordPress 설치, DB 연결, HTTPS 적용까지 자동
- **보안 강화**: ALB 및 RDS 보안그룹 구성, HTTP→HTTPS 리다이렉션
- **확장성**: Auto Scaling Group과 Launch Template 기반
- **환경변수화**: `terraform.tfvars`로 환경별 배포 가능
- **최적화된 캐싱**: CloudFront Cache Policy + Origin Request Policy 적용

---

```
## 디렉토리 구조

📂 dev-infra-wp
└── seocho_project
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    ├── versions.tf
    └── modules
        ├── vpc
        │   ├── main.tf          # VPC, Subnet, IGW, NAT, Route table
        │   ├── variables.tf
        │   └── outputs.tf
        ├── ec2
        │   ├── main.tf          # Launch Template / ASG / SG
        │   ├── user_data.sh     # WP 설치 & 프록시 HTTPS 인식
        │   ├── variables.tf
        │   └── outputs.tf
        ├── rds
        │   ├── main.tf          # MariaDB 인스턴스 / 파라미터 / SG
        │   ├── variables.tf
        │   └── outputs.tf
        ├── alb
        │   ├── main.tf          # ALB, Listener(443), Rules
        │   ├── variables.tf
        │   └── outputs.tf
        ├── cloudfront
        │   ├── main.tf          # Distribution, Cache/Origin Policies
        │   ├── variables.tf
        │   └── outputs.tf
        ├── route53
        │   ├── main.tf          # A/AAAA/ALIAS (도메인, origin)
        │   ├── variables.tf
        │   └── outputs.tf
        ├── acm
        │   ├── main.tf          # us-east-1(CF), ap-northeast-2(ALB) 인증서
        │   ├── variables.tf
        │   └── outputs.tf
        └── bastion
            ├── main.tf          # Bastion EC2 & SG (옵션)
            ├── variables.tf
            └── outputs.tf

```

---

## ⚙ 사전 준비
- AWS 계정 (Administrator 권한 IAM User)
- Terraform >= 1.5
- Route 53에 등록된 도메인

---

## 🚀 배포 방법
```bash
# 1. Terraform 초기화
terraform init

# 2. 배포 계획 확인
terraform plan

# 3. 인프라 생성
terraform apply -auto-approve
```
---

## 🔐 HTTPS 구성 흐름

사용자 → HTTPS → CloudFront → HTTPS → ALB → HTTP → EC2(WordPress)


- CloudFront: TLS 인증 및 글로벌 캐시
- ALB: ACM 인증서 기반 HTTPS 종료
- WordPress: 프록시 환경에서도 HTTPS 인식 가능하게 설정

---

## ✅ 검증 체크리스트
1. `https://도메인` 접속 시 WordPress 설치 페이지 노출
2. 브라우저에서 SSL 인증서 정상 표시
3. `curl -I https://도메인` 시 `X-Cache: Hit from cloudfront` 확인
4. `https://origin.도메인` 접속 시 ALB 직통 페이지 확인

---

## 🛠 문제 해결 팁
- **HTTPS 안 됨** → ALB 443 리스너에 인증서 연결 여부 확인
- **리다이렉션 루프** → `wp-config.php`에 `X-Forwarded-Proto` 처리 코드 추가
- **캐시 정책 오류** → `no_cache` / `cache_default` 분리

---

## 📌 향후 개선
- AWS WAF 적용해 보안 강화
- CloudWatch 기반 모니터링/알람
- CI/CD 파이프라인 연동

