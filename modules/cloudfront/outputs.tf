# CloudFront 배포 도메인 이름 출력
output "distribution_domain_name" {
  value = aws_cloudfront_distribution.cf.domain_name
}

# CloudFront Hosted Zone ID 출력
output "distribution_zone_id" {
  value = aws_cloudfront_distribution.cf.hosted_zone_id
}
