module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  # Enable control plane logging for several log types:
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  eks_managed_node_groups = {
    worker_group = {
      ami_type       = "AL2_x86_64"
      instance_types = ["m6i.large"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}