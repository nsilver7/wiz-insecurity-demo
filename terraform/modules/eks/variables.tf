variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID in which to deploy the cluster."
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs to use for the cluster."
  type        = list(string)
}