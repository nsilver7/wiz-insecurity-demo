packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "old_amzn_linux" {
  region                      = "us-west-2"
  vpc_id                      = "vpc-0c094a092731a9a98"
  subnet_id                   = "subnet-006351571872ef115"
  associate_public_ip_address = true
  # Use an official Amazon Linux 2 as base. We will simulate outdated behavior.
  source_ami_filter {
    filters = {
      name                    = "amzn-ami-hvm-*x86_64-gp2"
      virtualization-type     = "hvm"
      state                   = "available"
    }
    most_recent               = true
    owners                    = ["137112412989"]
    include_deprecated        = true
  }
  instance_type               = "t2.micro"
  ssh_username                = "ec2-user"
  ami_name                    = "custom-outdated-amzn-linux-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.old_amzn_linux"]

  provisioner "shell" {
    inline = [
      "sleep 30", // wait for yum lock to clear
      "sudo yum update -y",
      # Install an outdated version of MongoDB (e.g., version 3.2.x) – adjust repository or version as needed.
      "sudo tee /etc/yum.repos.d/mongodb-org-3.2.repo <<EOF",
      "[mongodb-org-3.2]",
      "name=MongoDB Repository",
      "baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.2/x86_64/",
      "gpgcheck=1",
      "enabled=1",
      "gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc",
      "EOF",
      "sudo yum install -y mongodb-org-3.2.22",
      "sudo service mongod start",
      "sudo chkconfig mongod on"
    ]
  }
}
