variable "project" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "app_security_group_id" {
  type    = string
  default = ""
}
variable "db_password" { type = string }

data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------
# IV-09/IV-10 REMEDIATED — DB subnet group uses PRIVATE subnets
# ---------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.environment}-db-subnet"
  subnet_ids = var.private_subnet_ids
}

# ---------------------------------------------------------------------------
# IV-02/IV-10 REMEDIATED — DB security group only allows 5432 from inside the
# VPC (the app security group), never from the internet
# ---------------------------------------------------------------------------
resource "aws_security_group" "db" {
  name        = "${var.project}-${var.environment}-db-sg"
  description = "Postgres access from application tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres from application tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.app_security_group_id != "" ? [var.app_security_group_id] : []
  }

  egress {
    description = "Restricted egress within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# ---------------------------------------------------------------------------
# KMS key for RDS storage + Performance Insights encryption
# ---------------------------------------------------------------------------
resource "aws_kms_key" "rds" {
  description             = "${var.project} RDS encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "EnableRootAccount"
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action    = "kms:*"
      Resource  = "*"
    }]
  })
}

# ---------------------------------------------------------------------------
# IAM role for RDS Enhanced Monitoring
# ---------------------------------------------------------------------------
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project}-${var.environment}-rds-monitoring"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ---------------------------------------------------------------------------
# CKV2_AWS_30 REMEDIATED — parameter group enabling Postgres query logging
# ---------------------------------------------------------------------------
resource "aws_db_parameter_group" "postgres_logging" {
  name   = "${var.project}-${var.environment}-pg14-logging"
  family = "postgres14"

  parameter {
    name  = "log_statement"
    value = "all"
  }
  parameter {
    name  = "log_min_duration_statement"
    value = "1"
  }
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
}

# ---------------------------------------------------------------------------
# IV-09 REMEDIATED — auth database: encrypted, private, backed up, protected
# ---------------------------------------------------------------------------
resource "aws_db_instance" "auth" {
  identifier     = "${var.project}-${var.environment}-authdb"
  engine         = "postgres"
  engine_version = "14"
  parameter_group_name = aws_db_parameter_group.postgres_logging.name
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_name        = "authdb"
  username       = "authuser"
  password       = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible                 = false
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.rds.arn
  backup_retention_period             = 14
  deletion_protection                 = true
  iam_database_authentication_enabled = true
  copy_tags_to_snapshot               = true
  auto_minor_version_upgrade          = true
  multi_az                            = true

  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.rds.arn
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  final_snapshot_identifier = "${var.project}-${var.environment}-authdb-final"
  skip_final_snapshot       = false
}

# ---------------------------------------------------------------------------
# IV-09 REMEDIATED — transaction database: same controls
# ---------------------------------------------------------------------------
resource "aws_db_instance" "transactions" {
  identifier     = "${var.project}-${var.environment}-txdb"
  engine         = "postgres"
  engine_version = "14"
  parameter_group_name = aws_db_parameter_group.postgres_logging.name
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_name        = "transactiondb"
  username       = "txuser"
  password       = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible                 = false
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.rds.arn
  backup_retention_period             = 14
  deletion_protection                 = true
  iam_database_authentication_enabled = true
  copy_tags_to_snapshot               = true
  auto_minor_version_upgrade          = true
  multi_az                            = true

  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.rds.arn
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  final_snapshot_identifier = "${var.project}-${var.environment}-txdb-final"
  skip_final_snapshot       = false
}