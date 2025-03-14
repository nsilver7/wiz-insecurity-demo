module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

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

  # Automatically adds the current caller identity as a cluster admin.
  enable_cluster_creator_admin_permissions = true

  # **Grant Bastion VM Role Access to the EKS Cluster**
  access_entries = {
    bastion_vm_role = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/db_vm_role"
      type          = "STANDARD"
      #kubernetes_groups = ["system:masters"]
    }
  }
}

# Let me DB / Bastion VM talk to k8s control plane
resource "aws_security_group_rule" "eks_allow_db_vm" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = aws_security_group.db_vm_sg.id
  description              = "Allow MongoDB VM to communicate with EKS API"
}