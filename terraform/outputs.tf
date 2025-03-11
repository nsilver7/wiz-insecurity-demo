output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks.cluster_id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "The public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "The private subnet IDs"
  value       = module.vpc.private_subnets
}