# 프로젝트 이름(prefix로 사용)
variable "project_name" {
  type        = string
  description = "Project name used as resource/tag prefix"
}

# VPC ID
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

# Private 서브넷 ID 목록
variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for RDS"
}

# RDS 인스턴스 클래스
variable "instance_class" {
  type        = string
  description = "RDS instance class"
}

# DB 이름
variable "db_name" {
  type        = string
  description = "Database name"
}

# DB 사용자명
variable "db_user" {
  type        = string
  description = "Master username"
}

# DB 비밀번호
variable "db_password" {
  type        = string
  description = "Master password"
}

# EC2 보안 그룹 ID (RDS 접근 허용)
variable "ec2_sg_id" {
  type        = string
  description = "Security Group ID of the EC2 instances that can access RDS"
}
