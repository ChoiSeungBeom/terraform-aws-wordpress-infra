# Terraform으로 CloudFront→ALB→EC2→RDS: WordPress HTTPS 인프라 만들기

> **TL;DR**: 도메인/인증서/캐시까지 포함된 WordPress HTTPS 인프라를 Terraform으로 자동 구성했다.  
> CloudFront 인증서는 us-east-1, 오리진(ALB)은 서울. 무캐시 경로와 RDS 보안그룹 참조로 안정성과 보안을 챙겼다.

## 배경
회사 포트폴리오/학습 목적의 템플릿이 필요했다. 수동 클릭 대신 **재현 가능한 코드 기반 배포**를 지향.

## 목표
- `terraform apply` 한 번으로 HTTPS WordPress 배포
- 전형적인 **CloudFront → ALB → EC2(ASG) → RDS** 구조
- 최소권한 보안(SG 참조), 캐시/무캐시 정책, 도메인/인증서 자동화

## 아키텍처
![Architecture](https://raw.githubusercontent.com/<YOUR_ID>/<REPO>/main/docs/architecture.png)
- DNS(Route 53): root/www→CF, origin→ALB
- CDN/SSL: CF + ACM(us-east-1)
- Origin: ALB(HTTPS)→EC2(ASG)
- DB: RDS(MySQL), Private Subnet

## Workflow
### Runtime
Users → HTTPS → CloudFront → HTTPS → ALB → HTTP → EC2 → RDS → 응답  
(프록시 환경 인지: `X-Forwarded-Proto`/`CloudFront-Forwarded-Proto`)

### Provisioning
terraform init → plan → apply → CF/Route53 전파 확인

## 핵심 설계 포인트
- **ACM(us-east-1)**: CloudFront 전용 인증서, 리전 고정 특성
- **RDS SG 참조**: CIDR 대신 EC2 SG 참조로 최소권한
- **무캐시 경로**: `/wp-login.php`, `/wp-admin/*`, `/wp-json/*`은 캐시 비활성 & 모든 뷰어 값 전달
- **오리진 HTTPS**: `origin_protocol_policy = "https-only"`

## 코드 하이라이트
```hcl
# CloudFront → ALB: HTTPS only
custom_origin_config {
  http_port              = 80
  https_port             = 443
  origin_protocol_policy = "https-only"
  origin_ssl_protocols   = ["TLSv1.2"]
}
```

```hcl
# RDS: SG 참조 방식
vpc_security_group_ids = [aws_security_group.rds_sg.id]
# ingress: security_groups = [var.ec2_sg_id]
```

```hcl
# Route 53: A-ALIAS to CF
alias {
  name                   = var.cloudfront_domain_name
  zone_id                = var.cloudfront_zone_id
  evaluate_target_health = false
}
```

```bash
# UserData: WordPress + HTTPS 인지 (일부)
fastcgi_param HTTPS $xfp_https;
```

## 실행 방법
```bash
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## 비용/운영 팁
- NAT GW/CF/RDS는 상시 과금, 교차 AZ 트래픽 고려
- RDS: `backup_retention_period`, `deletion_protection`, `storage_encrypted`
- (옵션) CF→ALB 비밀 헤더 + ALB 룰(미일치 403)

## 트러블슈팅
- HTTPS 미동작 → ALB 443 리스너/ACM 연결 확인
- 루프 → `wp-config.php` HTTPS 인지 코드
- CF 반영 지연 → Invalidation 또는 전파 대기

## 링크
- GitHub: https://github.com/<YOUR_ID>/<REPO>
- 아키텍처 캡처/스크린샷: `docs/` 폴더 참조 (Velog 에디터에 직접 업로드하거나 GitHub Raw URL 사용)
