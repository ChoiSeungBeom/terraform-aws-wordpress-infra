output "alb_dns_name" {
  description = "ALB DNS 이름"
  value       = module.alb.alb_dns_name
}

output "cloudfront_url" {
  description = "CloudFront 도메인 이름"
  value       = module.cloudfront.distribution_domain_name
}

output "bastion_ip" {
  description = "Bastion Public IP"
  value       = module.bastion.bastion_public_ip
}


output "alb_zone_id" {
  value = module.alb.alb_zone_id
}
