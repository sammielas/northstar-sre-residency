output "cluster_name" {
  value = aws_eks_cluster.northstar.name
}

output "cluster_status" {
  value = aws_eks_cluster.northstar.status
}

output "cluster_endpoint" {
  value = aws_eks_cluster.northstar.endpoint
}

output "node_group_name" {
  value = aws_eks_node_group.northstar.node_group_name
}

output "node_group_status" {
  value = aws_eks_node_group.northstar.status
}

output "network_vpc_id" {
  value = data.terraform_remote_state.network.outputs.vpc_id
}

output "network_subnet_ids" {
  value = data.terraform_remote_state.network.outputs.public_subnet_ids
}
