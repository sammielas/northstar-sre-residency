variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "floci_endpoint" {
  type    = string
  default = "http://localhost:4566"
}

variable "cluster_name" {
  type    = string
  default = "northstar-dev"
}

variable "kubernetes_version" {
  type    = string
  default = "1.31"
}

variable "node_group_name" {
  type    = string
  default = "northstar-workers"
}

variable "desired_nodes" {
  type    = number
  default = 1
}

variable "minimum_nodes" {
  type    = number
  default = 1
}

variable "maximum_nodes" {
  type    = number
  default = 2
}
