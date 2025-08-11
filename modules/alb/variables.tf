# 프로젝트 이름(prefix로 사용)
variable "project_name" {
  type        = string
  description = "Project name used as resource/tag prefix"
}

# VPC ID
variable "vpc_id" {
  type        = string
  description = "VPC ID for ALB and security group"
}

# 퍼블릭 서브넷 ID 목록
variable "subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for ALB"
}

# ACM 인증서 ARN
variable "origin_certificate_arn" {
  type        = string
  description = "ACM ARN for origin.domain in the ALB region"
}
