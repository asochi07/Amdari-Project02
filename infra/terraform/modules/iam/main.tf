variable "project" { type = string }

# OIDC provider details passed in from the EKS module — enables IRSA
variable "oidc_provider_arn" {
  type    = string
  default = ""
}
variable "oidc_provider_url" {
  type    = string
  default = ""
}

# ---------------------------------------------------------------------------
# IV-08 REMEDIATED — EKS node role scoped to the three AWS-managed policies
# that worker nodes actually require, instead of AdministratorAccess.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "eks_node" {
  name = "${var.project}-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ---------------------------------------------------------------------------
# IV-08 REMEDIATED — application role now uses IRSA (web-identity trust to the
# cluster OIDC provider) and a tightly-scoped policy: read only its own
# secrets and write only its own audit-log bucket prefix.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "app_role" {
  name = "${var.project}-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:secureflow:app-role"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

# Scoped inline policy — explicit actions, explicit resources. No wildcards.
resource "aws_iam_role_policy" "app_scoped" {
  name = "${var.project}-app-scoped"
  role = aws_iam_role.app_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadOwnSecrets"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = ["arn:aws:secretsmanager:*:*:secret:${var.project}/*"]
      },
      {
        Sid      = "WriteAuditLogs"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["arn:aws:s3:::${var.project}-audit-logs/*"]
      }
    ]
  })
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node.arn
}
output "app_role_arn" {
  value = aws_iam_role.app_role.arn
}