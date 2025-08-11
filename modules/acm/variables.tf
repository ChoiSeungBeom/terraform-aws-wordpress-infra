# Route53 hosted zone
variable "hosted_zone" {
  type        = string
  description = "Route53 hosted zone name"
}

# 인증서 기본 도메인 
variable "domain_name" {
  type        = string
  description = "Certificate primary domain "
}

# 추가 도메인(SANs). 필요 없으면 빈 배열 유지
variable "sans" {
  type        = list(string)
  default     = []
  description = "Subject Alternative Names"
}

# 프로젝트 이름(prefix로 사용)
variable "project_name" {
  type        = string
  description = "Project name used as resource/tag prefix"
}
