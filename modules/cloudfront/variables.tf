# 프로젝트 이름(prefix로 사용)
variable "project_name" {
  type        = string
  description = "Project name used as resource/tag prefix"
}

# us-east-1 리전의 ACM 인증서 ARN
variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN in us-east-1"
}

# CloudFront 도메인 별칭 목록 (예: beom.cloud)
variable "aliases" {
  type        = list(string)
  description = "List of domain aliases (e.g. beom.cloud)"
}

# 오리진(ALB) 도메인 (예: origin.beom.cloud)
variable "origin_domain" {
  type        = string
  description = "Origin host for ALB (e.g., origin.beom.cloud)"
}
