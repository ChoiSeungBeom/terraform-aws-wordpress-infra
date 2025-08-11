# Bastion Host 퍼블릭 IP 출력
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

# Bastion Host 보안 그룹 ID 출력
output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

