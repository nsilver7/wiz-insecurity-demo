resource "aws_security_group" "db_vm_sg" {
  name        = "db-vm-sg"
  description = "Security group for the MongoDB VM"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow MongoDB access from EKS nodes"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    # This assumes you have an output from your EKS module for the worker nodes’ security group.
    # For example, if you’ve defined an output "node_security_group_id" in your eks.tf:
    security_groups = [module.eks.node_security_group_id]
  }

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
