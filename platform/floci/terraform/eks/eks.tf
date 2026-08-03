resource "aws_eks_cluster" "northstar" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = data.terraform_remote_state.network.outputs.public_subnet_ids

    endpoint_private_access = false
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy.eks_cluster
  ]
}

resource "aws_eks_node_group" "northstar" {
  cluster_name    = aws_eks_cluster.northstar.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = data.terraform_remote_state.network.outputs.public_subnet_ids

  scaling_config {
    desired_size = var.desired_nodes
    min_size     = var.minimum_nodes
    max_size     = var.maximum_nodes
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy.eks_node
  ]
}
