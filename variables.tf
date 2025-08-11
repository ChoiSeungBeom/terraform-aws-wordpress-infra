# DB 이름
variable "db_name" {
  type        = string
  description = "DB name for RDS"
}

# DB 사용자
variable "db_user" {
  type        = string
  description = "DB user"
}

# DB 비밀번호 
variable "db_password" {
  type        = string
  description = "DB password"
  sensitive   = true
}

# RDS 인스턴스 클래스
variable "instance_class" {
  type        = string
  description = "RDS instance type "
}

# AMI ID (EC2/Bastion 공용)
variable "ami_id" {
  type        = string
  description = "AMI ID used for EC2/Bastion"
}

# EC2/Bastion 인스턴스 타입
variable "instance_type" {
  type        = string
  description = "Instance type for EC2/Bastion "
}

# SSH 키 페어 이름 (EC2/Bastion 공용)
variable "key_name" {
  type        = string
  description = "SSH key pair name for EC2/Bastion"
}

# SSH 허용 IP/CIDR
variable "allowed_ip" {
  type        = string
  description = "IP/CIDR block allowed for SSH"

}

# 루트 도메인 (Route53)
variable "domain" {
  type        = string
  description = "Route53 domain name"

}

# 프로젝트 이름 (네이밍/태그 prefix)
variable "project_name" {
  type        = string
  description = "Project name used as resource/tag prefix"

}
