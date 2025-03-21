locals {
  # this is gross
  my_ip = "107.193.220.138/32"

  # Static subset of GitHub Actions IPs (see: https://api.github.com/meta)
  # curl https://api.github.com/meta | jq '.actions'
  # quote limit of 60 CIDRs for SGs in AWS so this is a partial list  
  github_actions_ips = [
    "4.152.0.0/15",
    "4.154.0.0/15",
    "4.156.0.0/15",
    "4.208.0.0/15",
    "13.80.0.0/15",
    "13.84.0.0/15",
    "108.142.0.0/15",
    "172.168.0.0/15",
    "172.176.0.0/15",
    "172.180.0.0/15",
    "172.184.0.0/15",
    "172.190.0.0/15",
    "4.148.0.0/16",
    "4.151.0.0/16",
    "4.175.0.0/16",
    "4.180.0.0/16",
    "4.207.0.0/16",
    "9.163.0.0/16",
    "13.64.0.0/16",
    "13.65.0.0/16",
    "13.74.0.0/16",
    "13.79.0.0/16",
    "13.82.0.0/16",
    "13.83.0.0/16",
    "13.89.0.0/16",
    "13.90.0.0/16",
    "13.91.0.0/16",
    "13.92.0.0/16",
    "0.0.0.0/0"
    "20.0.0.0/8"
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
