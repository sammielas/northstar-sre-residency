output "vpc_id" {
  description = "Northstar VPC ID."
  value       = aws_vpc.northstar.id
}

output "vpc_cidr" {
  description = "Northstar VPC CIDR."
  value       = aws_vpc.northstar.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the future EKS cluster."
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
  ]
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  value = [
    aws_subnet.public_a.cidr_block,
    aws_subnet.public_b.cidr_block,
  ]
}

output "internet_gateway_id" {
  description = "Internet Gateway ID."
  value       = aws_internet_gateway.northstar.id
}

output "public_route_table_id" {
  description = "Public route-table ID."
  value       = aws_route_table.public.id
}
