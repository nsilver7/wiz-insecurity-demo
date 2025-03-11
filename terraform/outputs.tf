output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks.cluster_id
}