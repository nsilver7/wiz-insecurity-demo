module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.0.3"

  cluster_name    = var.cluster_name
  cluster_version = "1.21"  # supported k8s version
  subnets         = var.subnets
  vpc_id          = var.vpc_id

  # worker group configuration
  worker_groups_launch_template = [
    {
      name                    = "worker-group"
      instance_type           = "t3.medium"
      asg_desired_capacity    = 2
    }
  ]
}
