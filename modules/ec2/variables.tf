# 프로젝트 이름(prefix로 사용)
variable "project_name" {
  type        = string
  description = "Project name used as resource/tag prefix"
}

# VPC ID
variable "vpc_id" {
  type        = string
  description = "VPC ID where EC2 will be deployed"
}

# Private 서브넷 ID 목록
variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EC2"
}

# EC2 AMI ID
variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances"
}

# EC2 인스턴스 타입
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

# ALB 보안 그룹 ID
variable "alb_sg_id" {
  type        = string
  description = "Security Group ID of ALB that forwards traffic to EC2"
}

# ALB 타겟 그룹 ARN
variable "target_group_arn" {
  type        = string
  description = "Target Group ARN to register EC2 instances"
}

# DB 엔드포인트
variable "db_endpoint" {
  type        = string
  description = "Database endpoint for WordPress"
}

# DB 사용자명
variable "db_user" {
  type        = string
  description = "Database username"
}

# DB 비밀번호
variable "db_password" {
  type        = string
  description = "Database password"
}

# DB 이름
variable "db_name" {
  type        = string
  description = "Database name"
}

# Bastion 보안 그룹 ID (SSH 허용)
variable "bastion_sg_id" {
  type        = string
  description = "Bastion Security Group ID to allow SSH"
}

# SSH 키 페어 이름
variable "key_name" {
  type        = string
  description = "SSH key pair name for EC2"
}

# WordPress 도메인
variable "domain" {
  type        = string
  description = "Primary domain name for WordPress site URL"
}
