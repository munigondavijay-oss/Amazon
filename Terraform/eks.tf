############################################
# 📦 ECR Repository
############################################
resource "aws_ecr_repository" "app_repo" {
  name = "my-amazon-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "my-amazon-repo"
  }
}

############################################
# 🌐 Default VPC
############################################
data "aws_vpc" "default" {
  default = true
}

############################################
# 🌐 Filtered Subnets (ONLY SUPPORTED AZs)
############################################
data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  # ✅ IMPORTANT: Only supported AZs
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}

############################################
# ☸️ EKS Cluster
############################################
resource "aws_eks_cluster" "eks" {
  name     = "eks-amazon-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.eks_subnets.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

############################################
# 🖥️ EKS Node Group
############################################
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-amazon-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = data.aws_subnets.eks_subnets.ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  # ✅ Fix Fleet error
  capacity_type = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]
}

############################################
# 📤 Outputs
############################################
output "cluster_name" {
  value = aws_eks_cluster.eks.name
}