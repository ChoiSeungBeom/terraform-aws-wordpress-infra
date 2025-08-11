# ALB DNS 이름 출력
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

# 타겟 그룹 ARN 출력
output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

# ALB 보안 그룹 ID 출력
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

# ALB 호스티드 존 ID 출력
output "alb_zone_id" {
  value = aws_lb.alb.zone_id
}
