output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group associated with the EKS cluster."
  value       = module.eks.cluster_security_group_id
}