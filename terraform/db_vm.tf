locals {
  # this is gross
  my_ip = "107.193.220.138/32"

  # Static subset of GitHub Actions IPs (see: https://api.github.com/meta)
  # curl https://api.github.com/meta | jq '.actions'  
  github_actions_ips = [
    "185.199.108.0/22",
    "140.82.112.0/20",
  ]
}

resource "aws_security_group" "db_vm_sg" {
  name        = "db-vm-sg"
  description = "Security group for the MongoDB VM"
  vpc_id      = module.vpc.vpc_id

  # SSH from your IP
  ingress {
    description = "Allow SSH from my home IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  # SSH from GitHub Actions runners
  dynamic "ingress" {
    for_each = local.github_actions_ips
    content {
      description = "Allow SSH from GitHub Actions"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # MongoDB access from EKS
  ingress {
    description     = "Allow MongoDB access from EKS nodes"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  # All outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "db_vm" {
  ami                         = var.db_vm_ami
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.db_vm_sg.id]
  key_name                    = var.key_name
  iam_instance_profile        = module.iam.db_vm_instance_profile_name

  tags = {
    Name        = "MongoDB-VM"
    Environment = "demo"
  }
}
