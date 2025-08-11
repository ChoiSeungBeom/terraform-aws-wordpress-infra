# asg 이름 출력
output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

# EC2 sg ID 출력
output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}
