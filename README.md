# TPB — AWS · Terraform 기반 WordPress HTTPS 인프라

## 개요
Terraform으로 **CloudFront → ALB(HTTPS) → EC2(ASG) → RDS(MySQL)** 를 자동 배포합니다. **Route 53/ACM** 포함, `terraform apply` 한 번으로 **HTTPS 강제** 환경을 재현합니다.

## 아키텍처 요약
- **DNS**: Route 53 — `root/www → CloudFront`, `origin → ALB` (**A-ALIAS**)
- **TLS**: CloudFront(us-east-1 ACM) ↔ ALB(ap-northeast-2 ACM)  
- **오리진**: ALB(HTTPS) → EC2 Auto Scaling(UserData로 WP 설치)  
- **DB**: RDS(MySQL 8), **Private Subnet**, EC2 SG 참조만 허용

#### 아키텍처 다이어그램

![아키텍처 다이어그램](docs/images/architecture-overview.png)

> **무엇을 넣나**: CloudFront → ALB(HTTPS) → EC2(ASG) → RDS(MySQL) 전체 흐름과, Route 53 A(ALIAS) 및 ACM 연결 관계.  
> **작성 팁**: diagrams.net(draw.io) 또는 Excalidraw로 제작. 퍼블릭 IP/계정 식별 정보는 제거/모자이크.

## 모듈 구성
- `modules/vpc`, `modules/alb`, `modules/ec2`, `modules/rds`, `modules/cloudfront`, `modules/route53`, `modules/acm`, `modules/bastion`

## 이미지 가이드 & 체크리스트

> **권장 경로**: `docs/images/` (리포지토리 내 문서 전용 폴더)
>
> **촬영 원칙**: 민감정보(계정 ID, Zone ID, 엔드포인트, ARN 일부)는 모자이크·가림 처리. 화면 상단의 리전/계정 닉네임도 가리는 것을 권장.

| 파일 경로 | 무엇을 보여주나 | 어디서 캡처 | 보안/주의 |
|---|---|---|---|
| `docs/images/architecture-overview.png` | 전체 아키텍처(CloudFront → ALB → EC2(ASG) → RDS, Route53/ACM 연결) | 다이어그램 도구 | IP/Account 제거 |
| `docs/images/vpc-subnets.png` | VPC와 서브넷 AZ 배치(퍼블릭/프라이빗) | AWS 콘솔 → VPC → Subnets | VPC ID/Account ID 마스킹 |
| `docs/images/alb-listeners.png` | ALB 리스너(:80→:443 리다이렉트, :443→TG)와 인증서 연결 | EC2 → Load Balancers → Listeners | 인증서 ARN 일부 가림 |
| `docs/images/target-group-health.png` | Target Group 헬스체크(경로 `/wp-login.php`, 200–399) | EC2 → Target Groups | 프라이빗 IP 가림 |
| `docs/images/cloudfront-distribution.png` | CF Distribution(Origins/Behaviors, origin protocol=https-only) | CloudFront 콘솔 | 도메인 일부 마스킹 |
| `docs/images/route53-records.png` | Route 53 A(ALIAS) 레코드(root/www→CF, origin→ALB) | Route 53 → Hosted zones | Hosted Zone ID 가림 |
| `docs/images/rds-security.png` | RDS 서브넷 그룹/보안그룹(EC2 SG 참조, 3306 최소권한) | RDS/EC2 → Security groups | 엔드포인트 마스킹 |
| `docs/images/asg-launch-template.png` | ASG & Launch Template(UserData로 Nginx/PHP/WP 설치) | EC2 → Auto Scaling groups | UserData 내 민감정보 제거 |
| `docs/images/wp-https-redirect.png` | 브라우저에서 HTTPS 패드락/리디렉션 확인 화면 | 웹 브라우저 | URL 일부 마스킹 |
| `docs/images/cf-response-headers.png` | `curl -I` 응답 헤더(X-Cache, HTTP/2) 캡처 | 터미널 | 도메인만 노출, 쿠키 제거 |
| `docs/images/terraform-apply.png` | `terraform apply` 성공 로그(리소스 요약) | 터미널 | state/backends 비공개 |

**이미지 파일 구조 예시**
```bash
docs/
└── images/
    ├── architecture-overview.png
    ├── vpc-subnets.png
    ├── alb-listeners.png
    ├── target-group-health.png
    ├── cloudfront-distribution.png
    ├── route53-records.png
    ├── rds-security.png
    ├── asg-launch-template.png
    ├── wp-https-redirect.png
    ├── cf-response-headers.png
    └── terraform-apply.png
```

## 빠른 시작
```bash
# 1) 변수 템플릿 복사
cp terraform.tfvars.example terraform.tfvars

# 2) 초기화/플랜/배포
terraform init
terraform plan
terraform apply

# 3) 검증
curl -I https://<도메인>  # X-Cache / HTTP/2 확인
```

## 주요 변수
| 변수 | 설명 | 사용처 |
|---|---|---|
| `project_name` | 리소스/태그 접두사 | 전 모듈 |
| `domain` | 루트 도메인 | ACM(us-east-1), CF Aliases, Route53 |
| `allowed_ip` | SSH 허용 CIDR | Bastion SG |
| `key_name` | SSH 키 페어 | Bastion/EC2 |
| `ami_id`/`instance_type` | AMI/인스턴스 타입 | EC2 Launch Template |
| `instance_class` | RDS 클래스 | RDS |
| `db_*` | DB 이름/유저/비밀번호 | RDS, EC2 UserData 치환 |

## 운영 팁
- **헬스체크**: TG path=`/wp-login.php`, matcher=200–399  
- **프록시 인지**: `wp-config.php`/Nginx에 `X-Forwarded-Proto` 반영  
- **캐시 무효화**: 변경 시 CloudFront **Invalidation** 활용

## 트러블슈팅(퀵)
- **HTTPS 4xx**: ALB :443 리스너에 올바른 ACM(ap-northeast-2) 연결 확인  
- **리다이렉션 루프**: `wp-config.php` 에 `FORCE_SSL_ADMIN`, Nginx `fastcgi_param HTTPS` 점검  
- **DNS 미연결**: Route 53 **A(ALIAS)** 대상 확인(`dig +short <도메인>`)  
- **캐시 지연**: Invalidation 실행, 응답 헤더 `X-Cache`/`X-Amz-Cf-Pop` 확인  
- **TG Unhealthy**: 경로/매처/SG(EC2↔ALB) 확인  
- **DB 연결 실패**: RDS Public Access=No, SG는 **EC2 SG 참조**로 3306 허용
