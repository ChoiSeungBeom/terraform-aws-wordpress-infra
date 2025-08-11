# VPC ID 출력
output "vpc_id" {
  value = aws_vpc.main.id
}

# 퍼블릭 서브넷 ID 리스트 출력
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

# 프라이빗 서브넷 ID 리스트 출력
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
