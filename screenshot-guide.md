# 📸 구현 스크린샷 가이드 (TPB Project)

README의 “구현 스크린샷” 섹션에 맞춰 **각 이미지에 무엇을 찍어야 하는지** 정리했습니다.  
괄호의 파일명/경로대로 저장하면 README에 바로 반영할 수 있습니다.

---

## 02-route53-alias.png — Route 53 Alias 레코드
- 경로: **Route 53 → Hosted zones → `<domain>`**
- 포함:
  - `A` (alias) **root**(`example.com`) → **CloudFront distribution**
  - `A` (alias) **www**(`www.example.com`) → **CloudFront distribution**
  - `A` (alias) **origin**(`origin.example.com`) → **ALB DNS**
  - TTL, “Alias to CloudFront/ALB” 표시
- 가림: Hosted zone ID, Account ID

---

## 03-cf-distribution.png — CloudFront 배포
- 경로: **CloudFront → Distributions → 해당 배포**
- 포함(Overview 탭): **Domain name**, **Status=Deployed/Enabled**, **Alternate domain names**(root/www), **Viewer certificate**(ACM us-east-1)
- 가능하면 **Behaviors**도 함께:
  - Default: `redirect-to-https`
  - Ordered: `/wp-login.php`, `/wp-json/*`, `/wp-admin/*` → **CachingDisabled** / **AllViewer**
- 가림: Distribution ID

---

## 04-acm-us-east-1.png — ACM(us-east-1, CloudFront용)
- 리전: **us-east-1**
- 경로: **ACM → Certificates**
- 포함: **Status=Issued**, **Domain name**(root/www), **Validation=DNS**
- 가림: ARN 일부, 계정 ID

---

## 05-acm-seoul.png — ACM(ap-northeast-2, ALB용)
- 리전: **ap-northeast-2**
- 경로: **ACM → Certificates**
- 포함: **Status=Issued**, **Domain name**(`origin.<domain>`)
- 가림: ARN 일부

---

## 06-alb-listeners.png — ALB 리스너/룰
- 경로: **EC2 → Load Balancers → ALB → Listeners**
- 포함: **HTTPS :443** 리스너, **Default action=Forward → <Target Group>**
  - (비밀 헤더 룰 적용 시) **Rule #1: Header 일치 → Forward**, **Default: Fixed 403**
- 가림: ALB ARN 일부

---

## 07-tg-health.png — Target Group Health
- 경로: **EC2 → Target groups → `<tg>` → Targets / Health checks**
- 포함: **Healthy** 인스턴스(2대), **Health check path=/wp-login.php**, **Matcher=200–399**
- 가림: 인스턴스 ID 뒷자리

---

## 08-asg.png — Auto Scaling Group
- 경로: **EC2 → Auto Scaling groups → `<asg>`**
- 포함: **Desired/Min/Max** (예: 2/1/3), **Instances=InService/Healthy**, **Launch template** 연결
- 가림: ASG ARN 일부

---

## 09-rds.png — RDS 데이터베이스
- 경로: **RDS → Databases → `<db>`**
- 포함: **Engine=MySQL 8.x**, **Public access=No**, **Endpoint**(가림 가능), **VPC/Subnet group**, **Security groups**
- 가림: Endpoint 일부, Resource ID

---

## 10-vpc-subnets-nat.png — VPC/서브넷/NAT
- 경로:
  - **VPC → Subnets**: Public/Private, AZ별 구분
  - **VPC → NAT Gateways**: NAT 상태 **Available**
  - (선택) **VPC → Route tables**: Private RT의 `0.0.0.0/0 → NAT` 라우트
- 포함: 퍼블릭/프라이빗/RT 대응이 한눈에 보이도록

---

## 11-bastion.png (옵션) — Bastion EC2
- 경로: **EC2 → Instances → Bastion**
- 포함: **Public IPv4**, **Subnet=Public**, **SG Inbound: 22/tcp from <allowed_ip>**
- 가림: Public IP 일부

---

## 12-wp-https-home.png — WordPress HTTPS 접속
- 브라우저 캡처
- 포함: 주소창 **https://<domain>** + **자물쇠(SSL)**, WP 설치/홈 화면
- 팁: 상단 주소창/자물쇠가 보이도록 넉넉히 캡쳐

---

## 13-curl-headers.png (옵션) — 응답 헤더 확인
```bash
curl -I https://<domain>
```
- 포함: `HTTP/2 200`, `x-cache: Hit from cloudfront`(또는 Miss), `via`, `date` 헤더
- 가림: 서버/프록시 내부 IP 노출 여부 확인

---

## 📁 파일 위치/이름 컨벤션
```
docs/screens/
  02-route53-alias.png
  03-cf-distribution.png
  04-acm-us-east-1.png
  05-acm-seoul.png
  06-alb-listeners.png
  07-tg-health.png
  08-asg.png
  09-rds.png
  10-vpc-subnets-nat.png
  11-bastion.png           # 옵션
  12-wp-https-home.png
  13-curl-headers.png      # 옵션
```

## 🔒 민감정보 가림 체크리스트
- 계정 ID, ARN, 리소스/배포 ID, 퍼블릭 IP, RDS Endpoint
- 필요 시 도메인/서브도메인 일부 블러 처리

## 🖼 캡처 팁
- 해상도: 가로 **1280–1600px** 권장, 핵심 영역만 **크롭**
- UI가 어두우면 브라우저/콘솔 확대(110~125%) 후 캡처
- 동일한 폰트·배경으로 **톤 통일**(포폴/Velog 시각 일관성↑)
