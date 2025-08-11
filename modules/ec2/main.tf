# EC2 SG
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow web traffic from ALB"
  vpc_id      = var.vpc_id

  # ALB → HTTP 허용
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [
      var.alb_sg_id
    ]
  }

  # Bastion → SSH 허용
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = [
      var.bastion_sg_id
    ]
  }

  # 아웃바운드 전체 허용
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# 런치 템플릿
resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  # UserData
  user_data = base64encode(
    templatefile(
      "${path.module}/user_data.sh",
      {
        db_endpoint = var.db_endpoint
        db_user     = var.db_user
        db_password = var.db_password
        db_name     = var.db_name
        domain      = var.domain
      }
    )
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web"
    }
  }
}

# 오토스케일링 그룹
resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web"
    propagate_at_launch = true
  }
}


