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

# Bastion이 위치할 퍼블릭 서브넷 ID
variable "subnet_id" {
  type        = string
  description = "Subnet ID for bastion host"
}

# Bastion AMI ID
variable "ami_id" {
  type        = string
  description = "AMI ID for bastion host"
}

# EC2 인스턴스 타입
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

# SSH 키 페어 이름
variable "key_name" {
  type        = string
  description = "SSH key pair name"
}

# SSH 접근 허용 CIDR (예: 본인 IP)
variable "allowed_ip" {
  type        = string
  description = "CIDR block to allow SSH access (e.g. your IP)"
}
