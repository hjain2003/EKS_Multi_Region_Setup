resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-${var.region}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  ami_type = "AL2023_x86_64_STANDARD"
  disk_size      = 20

  tags = {
    Name = "${var.project_name}-${var.region}-node-group"
  }
}
