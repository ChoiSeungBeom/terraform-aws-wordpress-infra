# 기본 리전 : 서울
provider "aws" {
  region = "ap-northeast-2"
}

# CF 인증서 (us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# VPC 모듈
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}

# ALB 모듈
module "alb" {
  source = "./modules/alb"

  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.public_subnet_ids
  origin_certificate_arn = module.acm_origin.certificate_arn
}

# Bastion Host 모듈
module "bastion" {
  source = "./modules/bastion"

  project_name  = var.project_name
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0]
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  allowed_ip    = var.allowed_ip
}

# EC2 + Auto Scaling 모듈
module "ec2" {
  source = "./modules/ec2"

  project_name  = var.project_name
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.private_subnet_ids
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  alb_sg_id        = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn
  bastion_sg_id    = module.bastion.bastion_sg_id

  db_endpoint = module.rds.db_endpoint
  db_user     = var.db_user
  db_password = var.db_password
  db_name     = var.db_name

  domain = var.domain
}

# RDS 모듈
module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids

  ec2_sg_id = module.ec2.ec2_sg_id

  instance_class = var.instance_class
  db_name        = var.db_name
  db_user        = var.db_user
  db_password    = var.db_password
}

# ACM 모듈 (CloudFront)
module "acm_cf" {
  source = "./modules/acm"

  providers = {
    aws = aws.us_east_1
  }

  project_name = var.project_name
  hosted_zone  = var.domain
  domain_name  = var.domain

  sans = [
    "www.${var.domain}"
  ]
}

# ACM 모듈 (Origin ALB)
module "acm_origin" {
  source = "./modules/acm"

  project_name = var.project_name
  hosted_zone  = var.domain
  domain_name  = "origin.${var.domain}"

  sans = []
}

# CloudFront 모듈
module "cloudfront" {
  source = "./modules/cloudfront"

  project_name        = var.project_name
  origin_domain       = "origin.${var.domain}"
  acm_certificate_arn = module.acm_cf.certificate_arn

  aliases = [
    var.domain,
    "www.${var.domain}"
  ]
}

# Route 53 모듈
module "route53" {
  source = "./modules/route53"

  domain    = var.domain
  subdomain = "www"

  cloudfront_domain_name = module.cloudfront.distribution_domain_name
  cloudfront_zone_id     = module.cloudfront.distribution_zone_id

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}
