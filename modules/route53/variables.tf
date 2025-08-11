variable "domain" {
  type        = string
  description = "hosted zone domain name"
}

# 서브도메인 
variable "subdomain" {
  type        = string
  default     = ""
  description = "Subdomain prefix"
}

# ALB 도메인/Hosted Zone ID
variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name"
}

variable "alb_zone_id" {
  type        = string
  description = "ALB hosted zone ID"
}

# CloudFront 도메인/Hosted Zone ID
variable "cloudfront_domain_name" {
  type        = string
  description = "CloudFront domain name(d1234abcd1234.cloudfront.net)"
}

variable "cloudfront_zone_id" {
  type        = string
  description = "CloudFront hosted zone ID"
}
