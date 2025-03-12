module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # Enable NAT gateway so private subnets can access the internet
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  # Tag public subnets for Kubernetes external load balancers
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  # Tag private subnets for internal load balancers
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

##----------------------##
## Public Route Table  ##
##----------------------##

resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "${module.vpc.name}-public-route-table"
  }
}

# Route internet traffic from public subnets through the Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc.igw_id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count = length(module.vpc.public_subnets)

  subnet_id      = module.vpc.public_subnets[count.index]
  route_table_id = aws_route_table.public.id
}

##----------------------##
## Private Route Table ##
##----------------------##

resource "aws_route_table" "private" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "${module.vpc.name}-private-route-table"
  }
}

# Route private subnet traffic through the NAT Gateway
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.vpc.natgw_ids[0]
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  count = length(module.vpc.private_subnets)

  subnet_id      = module.vpc.private_subnets[count.index]
  route_table_id = aws_route_table.private.id
}
