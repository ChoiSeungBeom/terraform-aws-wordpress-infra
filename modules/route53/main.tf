# Route53 호스티드 존 조회
data "aws_route53_zone" "selected" {
  name         = var.domain
  private_zone = false
}

# CF로 보낼 별칭 목록
locals {
  cf_alias_names = compact([
    var.domain,
    var.subdomain != "" ? "${var.subdomain}.${var.domain}" : ""
  ])
}

# 루트/서브 도메인 -> CloudFront Alias
resource "aws_route53_record" "cloudfront_alias" {
  for_each = toset(local.cf_alias_names)

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

# origin.domain -> ALB Alias
resource "aws_route53_record" "origin_alias" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "origin.${var.domain}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}
