variable "aws_region" {
  description = "AWS-compatible Region used by Floci."
  type        = string
  default     = "us-east-1"
}

variable "floci_endpoint" {
  description = "Floci AWS-compatible API endpoint."
  type        = string
  default     = "http://localhost:4566"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
  default     = "northstar"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "development"
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the Northstar VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet A."
  type        = string
  default     = "10.20.1.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet B."
  type        = string
  default     = "10.20.2.0/24"
}

variable "eks_cluster_name" {
  description = "Future Northstar EKS cluster name."
  type        = string
  default     = "northstar-dev"
}
