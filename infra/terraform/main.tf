# SecureFlow Terraform — REMEDIATED (Week 2 Day 8).
# All planted vulnerabilities resolved; Checkov passes across every module.
# IAM least-privilege + IRSA, S3/RDS encryption, private subnets, private EKS.
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "eu-west-2"
}
variable "project" {
  type    = string
  default = "secureflow"
}
variable "environment" {
  type    = string
  default = "dev"
}

# IV-01 REMEDIATED — password supplied at runtime via TF_VAR_db_password,
# never hardcoded. No default, marked sensitive.
variable "db_password" {
  type      = string
  sensitive = true
}

module "vpc" {
  source      = "./modules/vpc"
  project     = var.project
  environment = var.environment
}

module "eks" {
  source             = "./modules/eks"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "iam" {
  source            = "./modules/iam"
  project           = var.project
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

module "s3" {
  source  = "./modules/s3"
  project = var.project
}

module "rds" {
  source                = "./modules/rds"
  project               = var.project
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.vpc.app_security_group_id
  db_password           = var.db_password
}