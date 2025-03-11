module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # Create a NAT gateway so that private subnets can access the internet
  enable_nat_gateway = true
  single_nat_gateway = true

  # Tag public subnets for Kubernetes external load balancers
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  # Tag private subnets for internal load balancers
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
